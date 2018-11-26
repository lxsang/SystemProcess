Class {
	#name : #SharedMemStream,
	#superclass : #Object,
	#instVars : [
		'shName',
		'fp',
		'ptr',
		'memSize',
		'istream',
		'ostream',
		'id'
	],
	#category : #SystemProcess
}

{ #category : #'instance creation' }
SharedMemStream class >> on: shName [
	^self new shName: shName; yourself
]

{ #category : #accessing }
SharedMemStream >> atEnd [
	^ ostream atEnd
	
]

{ #category : #'initialize-release' }
SharedMemStream >> close [
	"fp ifNil: [ ^self ].
	self lib close:fp."
	ptr ifNotNil: [ self lib munmap: ptr  length: self memSize  ].
	self lib shm_unlink: self shName.
	ptr := nil
]

{ #category : #accessing }
SharedMemStream >> fp [
	^ fp
]

{ #category : #accessing }
SharedMemStream >> id [
	^id
]

{ #category : #initialization }
SharedMemStream >> initialize [
	super initialize.
	memSize :=  512 Kb.
	istream := SharedQueue new.
	ostream := SharedQueue new.
	id := Time now asMilliSeconds.
	
]

{ #category : #accessing }
SharedMemStream >> isOpen [
	^ self ptr isNotNil 
]

{ #category : #'instance creation' }
SharedMemStream >> lib [
	^ LibSystemProcess singleton
]

{ #category : #accessing }
SharedMemStream >> memSize [
	^ memSize
]

{ #category : #accessing }
SharedMemStream >> memSize: anObject [
	memSize := anObject
]

{ #category : #accessing }
SharedMemStream >> next [
	^ ostream next
]

{ #category : #accessing }
SharedMemStream >> nextPut: v [
	^ istream nextPut:v
]

{ #category : #accessing }
SharedMemStream >> nextPutAll: v [
	^ istream nextPutAll:v
]

{ #category : #'instance creation' }
SharedMemStream >> open [
	self shName ifNil: [ ^self error:'Shared name is empty' ].
	fp := self lib shm_open: self shName
		flag: (LibSystemProcess O_RDWR bitOr: LibSystemProcess  O_CREAT)
		mode: 420. "0644"
	fp = -1 ifTrue:[^self error: 'Cannot open shared memory:', self shName].
	self lib ftruncate: fp size: self memSize. 
	ptr := self lib 
				mmap: nil
				size: self memSize
				prot: (LibSystemProcess PROT_READ bitOr: LibSystemProcess PROT_WRITE )
				flags:  LibSystemProcess MAP_SHARED 
				fd: fp
				offset: 0.
	self lib close: fp.
	ptr getHandle asInteger = -1 ifTrue:[^self error: 'Unable to map to memory'].
	[ self process ] forkAt: Processor userBackgroundPriority
]

{ #category : #synchronization }
SharedMemStream >> process [
|mid|
"read first 8 bytes of mem"
[ self ptr isNotNil] whileTrue:[
	mid := self readId.
	mid = id ifFalse:[
		mid > 0 ifTrue:[self readData].
		self writeData: mid.
	].
].
]

{ #category : #accessing }
SharedMemStream >> ptr [
	^ ptr
]

{ #category : #synchronization }
SharedMemStream >> read [
	|mid anInt bytes|
	mid := self readId.
	mid = id ifTrue:[^nil].
	anInt := self readSize.
	bytes := self lib getReadWriteBufferOf: anInt.
	self lib memcpyTo: bytes from: self ptr + 8  size: anInt. 
	^FLMaterializer  materializeFromByteArray:(FFIExternalArray fromHandle: bytes type: 'uint8' size: anInt) asByteArray.
]

{ #category : #synchronization }
SharedMemStream >> readData [
	|data|
	data := self read.
	self ready.
	data ifNil: [ ^self ].
	ostream nextPut: data
]

{ #category : #synchronization }
SharedMemStream >> readId [
	^ self readInt32At: 0
]

{ #category : #synchronization }
SharedMemStream >> readInt32At:offset [
	|buff anInt|
	buff := self lib getReadWriteBufferOf: 4.
	self lib memcpyTo: buff from: self ptr + offset  size: 4.
	anInt := (FFIExternalArray fromHandle: buff type: 'uint8' size: 4) asByteArray asInteger.
	buff free.
	^anInt 
	
	 
]

{ #category : #synchronization }
SharedMemStream >> readSize [
	^ self readInt32At: 4
	
	 
]

{ #category : #synchronization }
SharedMemStream >> ready [
	|mid|
	mid := self readId.
	mid = id ifTrue:[^nil].
	self lib memcpyTo: self ptr from: (0 asByteArrayOfSize: 4) size: 4.
]

{ #category : #accessing }
SharedMemStream >> shName [
	^ shName
]

{ #category : #accessing }
SharedMemStream >> shName: anObject [
	shName := anObject
]

{ #category : #synchronization }
SharedMemStream >> write: anObject [
	|fuel anInt|
	fuel := FLSerializer serializeToByteArray: anObject.
	"lock the memory"
	self lib memcpyTo: self ptr from: (-1 asByteArrayOfSize: 4)   size: 4.
	anInt := fuel size asByteArrayOfSize: 4.
	self lib memcpyTo: self ptr + 4 from: anInt   size: 4.
	self lib memcpyTo: self ptr + 8 from: fuel   size: fuel size.
	anInt := id asByteArrayOfSize:4.
	self lib memcpyTo: self ptr from: anInt   size: 4.
	
]

{ #category : #synchronization }
SharedMemStream >> writeData:mid [
	mid = -1 ifTrue:[^self]. 
	istream atEnd ifTrue:[^self].
	self write: istream next
]
