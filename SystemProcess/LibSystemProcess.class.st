Class {
	#name : #LibSystemProcess,
	#superclass : #FFILibrary,
	#classInstVars : [
		'instance'
	],
	#category : #SystemProcess
}

{ #category : #'C-constants' }
LibSystemProcess class >> F_GETFL [
	^3
]

{ #category : #'C-constants' }
LibSystemProcess class >> F_SETFL [
	^4
]

{ #category : #'C-constants' }
LibSystemProcess class >> O_NONBLOCK [
	Smalltalk os isMacOS ifTrue: [ ^4 ].
	^4000
]

{ #category : #'C-constants' }
LibSystemProcess class >> O_RDWR [
	^2
]

{ #category : #'C-constants' }
LibSystemProcess class >> SIGKILL [
	^ 9
]

{ #category : #'instance creation' }
LibSystemProcess class >> new [
	self error: 'Please use #singleton'
]

{ #category : #'instance creation' }
LibSystemProcess class >> singleton [ 
	^ self uniqueInstance 
]

{ #category : #'C-constants' }
LibSystemProcess class >> sizeOfFileAction [
	"we fix it to 80 for now"
	^80
]

{ #category : #lib }
LibSystemProcess >> close: fd [
	^ self ffiCall: #(int close(int fd)) module: LibC
]

{ #category : #lib }
LibSystemProcess >> closept: fd [
	^ self ffiCall: #(int close(int fd)) module: LibC
]

{ #category : #'instance creation' }
LibSystemProcess >> exec: command [
	^ LibC uniqueInstance system: command
]

{ #category : #lib }
LibSystemProcess >> fileActionAddDup: pointer fd: fd newFd: fd2 [ 
	^self ffiCall: #(int posix_spawn_file_actions_adddup2( void* pointer, int fd, int fd2)) module: LibC.
]

{ #category : #lib }
LibSystemProcess >> fileActionAddOpen: pointer fd: fd fileName: name flag: flag mode: mode [ 
	^self ffiCall: #(int posix_spawn_file_actions_addopen( void* pointer, int fd, char* name, int flag, int mode )) module: LibC.
]

{ #category : #lib }
LibSystemProcess >> fileActionInit: pointer [
	^self ffiCall: #(int posix_spawn_file_actions_init( void* pointer )) module: LibC.
]

{ #category : #lib }
LibSystemProcess >> fnctl: fd action: action flag: flag [
 	^ self ffiCall: #(int fcntl(int fd, int action, int flag)) module: LibC 
]

{ #category : #writing }
LibSystemProcess >> getReadWriteBufferOf: size [
	^(FFIExternalArray externalNewType: 'char' size: size) getHandle
]

{ #category : #lib }
LibSystemProcess >> grantpt: fd [
	^ self ffiCall: #(int grantpt(int fd)) module: LibC
]

{ #category : #lib }
LibSystemProcess >> ioct: fd cmd: cmd arg: arg [
	^ self ffiCall: #(int ioctl(int fd, ulong cmd, void* arg)) module: LibC
]

{ #category : #accessing }
LibSystemProcess >> kill: pid signal: sig [
	^ self ffiCall: #(int kill(int pid, int sig)) module: LibC
]

{ #category : #'accessing platform' }
LibSystemProcess >> macModuleName [ 
	^ self moduleName 
]

{ #category : #accessing }
LibSystemProcess >> master [
	|fd st|
	fd := self openpt: (self class O_RDWR bitOr: self class O_NONBLOCK).
	fd < 0 ifTrue:[^self error:'Error on on posix_openpt()'].
	st := self grantpt: fd.
	st ~= 0 ifTrue: [ self close: fd. ^ self error: 'Error on grantpt()' ].
	st := self unlockpt: fd.
	st ~= 0 ifTrue: [ self close: fd. ^ self error: 'Error on unlockpt()' ].
	^fd
	
]

{ #category : #'accessing platform' }
LibSystemProcess >> moduleName [ 
	^ ''
]

{ #category : #lib }
LibSystemProcess >> open: name mode: flag [
	^ self ffiCall: #(int open(char* name, int flag)) module: LibC
]

{ #category : #lib }
LibSystemProcess >> openpt: flag [
	^ self ffiCall: #(int posix_openpt(int flag)) module: LibC
]

{ #category : #lib }
LibSystemProcess >> posixSpawn:pid  process: cmd fileAction: ptr fileAttr:fattr argv: args env: envs [
	^ self ffiCall:#( int posix_spawnp(int* pid, char* cmd, void* ptr, void* fattr, void* args, void* envs ))  module: LibC  
]

{ #category : #lib }
LibSystemProcess >> ptsname: fd [
	^ self ffiCall: #(char* ptsname(int fd)) module: LibC
]

{ #category : #lib }
LibSystemProcess >> read: fd buffer: buff size: size [
	^self ffiCall: #(int read(int fd, char* buff, int size)) module: LibC 
]

{ #category : #initialization }
LibSystemProcess >> setNonBlocking: fd [
	|flag st|
	flag := self fnctl: fd action: self class F_GETFL flag:0.
	flag := flag bitOr: self class O_NONBLOCK.
	st := self fnctl: fd action: self class F_SETFL flag: flag.
	st = 0 ifFalse:[^self error: 'Cannot set nonblocking'].
	^st
]

{ #category : #lib }
LibSystemProcess >> stringArrayOf: anArray [
	|xarray|
	anArray  ifNil: [ ^nil ].
	xarray := FFIExternalArray externalNewType: 'char*' size: anArray size + 1. 
	anArray withIndexDo: [ :v :i| xarray at:i put: (ExternalAddress fromString: v) ]. 
	xarray at:anArray size + 1 put: (ExternalAddress  fromAddress: 0).
	^ xarray 
]

{ #category : #'accessing platform' }
LibSystemProcess >> unixModuleName [
	^self moduleName
]

{ #category : #lib }
LibSystemProcess >> unlockpt: fd [
	^ self ffiCall: #(int unlockpt(int fd)) module: LibC
]

{ #category : #lib }
LibSystemProcess >> waitpid: pid status: buf noHang: v [
	^ self ffiCall: #(int waitpid(int pid, int * buf, int v)) module: LibC
]

{ #category : #writing }
LibSystemProcess >> write: fd buffer: buff size: size [
	^self ffiCall: #(int write(int fd, char* buff, int size)) module: LibC 
]

{ #category : #lib }
LibSystemProcess >> xspawn: fd argv: argv envs:envs [
	^ self ffiCall: #(int pterm_spawn_tty(int fd, void* argv, void* envs)) 
]
