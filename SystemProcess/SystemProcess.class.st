Class {
	#name : #SystemProcess,
	#superclass : #Object,
	#instVars : [
		'ostream',
		'istream',
		'pid',
		'master',
		'oblock',
		'fblock',
		'block'
	],
	#category : #SystemProcess
}

{ #category : #accessing }
SystemProcess >> cleanup [
	self finalizeProcess.
	master ifNotNil: [self lib close: master].
	istream ifNotNil: [istream close].
	ostream ifNotNil: [ostream close].
	master := nil.
	pid := nil.
	block := false
]

{ #category : #accessing }
SystemProcess >> environ [
	|collection|
	collection := OrderedCollection new.
	Smalltalk os environment asDictionary keysAndValuesDo: [ :k :v|
		collection add: k,'=',v
	].
	^collection 
]

{ #category : #shell }
SystemProcess >> fileActionSettingFor:name [
	|st ptr|
	ptr := ExternalAddress allocate: self lib class sizeOfFileAction.
	st := self lib fileActionInit: ptr.
	st = 0 ifFalse:[^ self error:'Error posix_spawn_file_actions_init'].
	istream ifNotNil: [
		st := self lib fileActionAddOpen: ptr fd: 0  fileName: name  flag: self lib class O_RDWR  mode: 0644. 
		st = 0 ifFalse: [ ^ self error:'Error posix_spawn_file_actions_open' ].
		ostream ifNotNil: [
			st := self lib fileActionAddDup: ptr fd: 0  newFd: 1.
			st = 0 ifFalse: [ ^self error: 'Error posix_spawn_file_action_dup2' ].
			st := self lib fileActionAddDup: ptr fd: 0  newFd: 2.
			st = 0 ifFalse: [ ^self error: 'Error posix_spawn_file_action_dup2' ].
		]
	] ifNil: [
		ostream ifNotNil:[
			st := self lib fileActionAddOpen: ptr fd: 1  fileName: name  flag: self lib class O_RDWR  mode: 0644. 
			st = 0 ifFalse: [ ^ self error:'Error posix_spawn_file_actions_open' ].
			st := self lib fileActionAddDup: ptr fd:1  newFd: 2.
			st = 0 ifFalse: [ ^self error: 'Error posix_spawn_file_action_dup2' ].
		]
	].
	
	^ ptr
]

{ #category : #accessing }
SystemProcess >> finalizeProcess [
	|ws status|
	pid ifNotNil:[
		status := FFIUInt32  newBuffer.
		ws := self lib waitpid: pid status: status noHang: 1.
		ws = 0 ifTrue:[
			self lib kill: pid signal: self lib class SIGKILL.
		].
		pid := nil
	].
]

{ #category : #initialization }
SystemProcess >> initialize [
	istream := nil.
	ostream := nil.
	block := false.
]

{ #category : #accessing }
SystemProcess >> istream [
	^ istream
]

{ #category : #accessing }
SystemProcess >> lib [
	^LibSystemProcess singleton 
]

{ #category : #event }
SystemProcess >> onFinishDo: aBlock [ 
	fblock := aBlock 
]

{ #category : #event }
SystemProcess >> onOutputDo: aBlock [ 
	oblock := aBlock 
]

{ #category : #accessing }
SystemProcess >> ostream [
	^ ostream
]

{ #category : #shell }
SystemProcess >> processFinish [
	block ifTrue: [ ^self ].
	block := true.
	fblock ifNotNil:[ fblock value ]
]

{ #category : #initialization }
SystemProcess >> redirectStdin [
	istream := SharedQueue new
]

{ #category : #initialization }
SystemProcess >> redirectStdout [
	ostream := SharedQueue new
]

{ #category : #shell }
SystemProcess >> shellCommand: cmd [
	^ self shellCommand: cmd env: self environ  
]

{ #category : #shell }
SystemProcess >> shellCommand: cmd env: env [
	| xarray  earray status  fname fileaction |
	"kill the existing process if any"
	self finalizeProcess.
	"spaw a new command"
	xarray := self lib stringArrayOf: cmd.
	earray  := self lib stringArrayOf: env.
	xarray ifNotNil: [ xarray := xarray getHandle ].
	earray ifNotNil: [ earray := earray getHandle ] ifNil: [Smalltalk os environment environ getHandle].
	master := self lib master.
	status := FFIUInt32  newBuffer.
	fname := self lib ptsname: master.
	fileaction  := self fileActionSettingFor:fname.
	ostream ifNotNil:[[ self waitForOutput  ] forkAt: Processor userSchedulingPriority].
	istream ifNotNil:[[ self waitForInput  ] forkAt: Processor userSchedulingPriority].
	(ostream isNil and: [ istream isNil ]) ifTrue: [ [self waitForFinish] forkAt: Processor userSchedulingPriority  ].
	self lib posixSpawn: status 
			process: (cmd at:1)
			fileAction: fileaction
			fileAttr: nil
			argv: xarray
			env: earray.
	pid := status integerAt: 1 size: 4 signed:true.
	fileaction free.
	Transcript show: 'Command run on process: ', pid asString; cr.
]

{ #category : #accessing }
SystemProcess >> stdinStream [
	^self istream 
]

{ #category : #accessing }
SystemProcess >> stdoutStream [
	^ self ostream
]

{ #category : #shell }
SystemProcess >> waitForFinish [
	|ws status|
	ws := 0.
	master ifNil: [ ^self ].
	status := FFIUInt32  newBuffer.
	[ 
		pid ifNotNil: [ 
			ws := self lib waitpid: pid status: status noHang: 1
		].
		ws = 0
	] whileTrue: [ 200 milliSeconds wait].
	self processFinish.
	Transcript  show: 'End of wait for input'; cr.
]

{ #category : #shell }
SystemProcess >> waitForInput [
	|ws status buff text|
	ws := 0.
	master ifNil: [ ^self ].
	status := FFIUInt32  newBuffer.
	[ 
		[istream atEnd] whileFalse: [
			text := istream next asString.
			buff := ExternalAddress fromString: text.
			self lib write: master buffer: buff  size: text size.
		].
		pid ifNotNil: [ 
			ws := self lib waitpid: pid status: status noHang: 1
		].
		ws = 0
	] whileTrue: [ istream atEnd ifFalse:[ 200 milliSeconds wait ]].
	ostream ifNil:[self processFinish].
	Transcript  show: 'End of wait for input'; cr.
]

{ #category : #shell }
SystemProcess >> waitForOutput [
	|data buff count ws status|
	ws := 0.
	master ifNil: [ ^self ].
	status := FFIUInt32  newBuffer.
	buff := self lib getReadWriteBufferOf: 2048.
	[ 
		count := self lib read: master buffer: buff  size: 2048.
		count > 0 ifTrue:[
			data :=  String newFrom: (FFIExternalArray fromHandle: buff type: 'char' size: count).
			ostream nextPutAll: data.
			oblock ifNotNil: [ oblock value:data ]
		].
		pid ifNotNil: [ 
			ws := self lib waitpid: pid status: status noHang: 1
		].
	ws = 0
	] whileTrue: [ count > 0 ifFalse:[ 200 milliSeconds wait ]].
	self processFinish.
	Transcript  show: 'End of wait for output'; cr.
]
