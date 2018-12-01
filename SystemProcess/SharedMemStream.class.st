Class {
	#name : #SharedMemStream,
	#superclass : #Object,
	#instVars : [
		'shName',
		'fp',
		'memSize',
		'istream',
		'ostream',
		'id',
		'rmem',
		'wmem',
		'lock',
		'proc'
	],
	#category : #SystemProcess
}

{ #category : #'instance creation' }
SharedMemStream class >> on: shName process: p [
	^self new shName: shName; proc: p; yourself
]

{ #category : #accessing }
SharedMemStream >> atEnd [
	^ ostream atEnd
	
]

{ #category : #'initialize-release' }
SharedMemStream >> close [
	"fp ifNil: [ ^self ].
	self lib close:fp."
	lock critical:[
		rmem ifNotNil: [ self lib munmap: rmem  length: self memSize  ].
		wmem ifNotNil: [ self lib munmap: wmem  length: self memSize  ].
		self lib shm_unlink: self shName,'_i'.
		self lib shm_unlink: self shName,'_o'.
		rmem := wmem := nil
	].
]

{ #category : #accessing }
SharedMemStream >> fp [
	^ fp
]

{ #category : #'instance creation' }
SharedMemStream >> getSharedMem: name [
	|ptr|
	fp := self lib shm_open: name
		flag: (LibSystemProcess O_RDWR bitOr: LibSystemProcess  O_CREAT)
		mode: 420. "0644"
	fp = -1 ifTrue:[^self error: 'Cannot open shared memory:', name].
	self lib ftruncate: fp size: self memSize. 
	ptr := self lib 
				mmap: nil
				size: self memSize
				prot: (LibSystemProcess PROT_READ bitOr: LibSystemProcess PROT_WRITE )
				flags:  LibSystemProcess MAP_SHARED 
				fd: fp
				offset: 0.
	self lib close: fp.
	ptr getHandle asInteger = -1 ifTrue:[^self error: 'Unable to map to memory of:', name].
	^ptr
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
	lock := Semaphore forMutualExclusion.
]

{ #category : #accessing }
SharedMemStream >> isOpen [
	^ rmem isNotNil & wmem isNotNil
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
	^ self open:false
]

{ #category : #'instance creation' }
SharedMemStream >> open: swap [
	|tmp|
	self shName ifNil: [ ^self error:'Shared name is empty' ].
	rmem := self getSharedMem: self shName, '_i'.
	wmem := self getSharedMem: self shName, '_o'.
	swap ifTrue:[tmp := rmem. rmem := wmem. wmem := tmp].
	[ self process ] forkAt: Processor userBackgroundPriority
]

{ #category : #accessing }
SharedMemStream >> proc [
	^ proc
]

{ #category : #accessing }
SharedMemStream >> proc: anObject [
	proc := anObject
]

{ #category : #accessing }
SharedMemStream >> process [
|mid|
"read first 8 bytes of mem"
[ self isOpen] whileTrue:[
	lock critical:[
		mid := self readIdFrom:rmem.
		mid > 0 ifTrue:[self readData ].
		mid := self readIdFrom: wmem.
		mid = 0 ifTrue:[self writeData].
	]
].
]

{ #category : #synchronization }
SharedMemStream >> read [
	|mid anInt bytes|
	mid := self readIdFrom: rmem.
	mid = id ifTrue:[^nil].
	anInt := self readSize.
	bytes := self lib getReadWriteBufferOf: anInt.
	self lib memcpyTo: bytes from: rmem + 8  size: anInt. 
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
SharedMemStream >> readIdFrom: mem [
	^ self readInt32At: 0 from:mem
]

{ #category : #synchronization }
SharedMemStream >> readInt32At:offset from: mem [
	|buff anInt|
	buff := self lib getReadWriteBufferOf: 4.
	self lib memcpyTo: buff from: mem + offset  size: 4.
	anInt := (FFIExternalArray fromHandle: buff type: 'uint8' size: 4) asByteArray asInteger.
	buff free.
	^anInt 
	
	 
]

{ #category : #synchronization }
SharedMemStream >> readSize [
	^ self readInt32At: 4 from: rmem
	
	 
]

{ #category : #synchronization }
SharedMemStream >> ready [
"	|mid|
	mid := self readIdFrom:.
	mid = id ifTrue:[^nil]."
	self lib memcpyTo: rmem from: (0 asByteArrayOfSize: 4) size: 4.
]

{ #category : #accessing }
SharedMemStream >> shName [
	^ shName
]

{ #category : #accessing }
SharedMemStream >> shName: anObject [
	shName := anObject
]

{ #category : #'initialize-release' }
SharedMemStream >> terminate [
	self close.
	proc ifNil: [ ^self ].
	proc cleanup
]

{ #category : #synchronization }
SharedMemStream >> write: anObject [
	|fuel anInt|
	"lock the memory"
	"id := self readId.
	id = -1 ifTrue:[^self]."
	"self lib memcpyTo: wmem from: (-1 asByteArrayOfSize: 4)   size: 4."
	fuel := FLSerializer serializeToByteArray: anObject.
	anInt := fuel size asByteArrayOfSize: 4.
	self lib memcpyTo: wmem + 4 from: anInt   size: 4.
	self lib memcpyTo: wmem + 8 from: fuel   size: fuel size.
	anInt := id asByteArrayOfSize:4.
	self lib memcpyTo: wmem from: anInt   size: 4.
	
]

{ #category : #synchronization }
SharedMemStream >> writeData [
	|mid|
	mid := self readIdFrom:wmem.
	mid = 0 ifFalse:[^self]. 
	istream atEnd ifTrue:[^self].
	self write: istream next
]
