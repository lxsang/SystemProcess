Class {
	#name : #InterVMChannel,
	#superclass : #InterVMBaseTransport,
	#category : #SystemProcess
}

{ #category : #'instance creation' }
InterVMChannel class >> headfull [
	|o|
	o := super new.
	o teleport  process.
	^o teleport
]

{ #category : #'instance creation' }
InterVMChannel class >> headfull: size [
	|o|
	o := super new.
	o setMemSize: size.
	o teleport  process.
	^o teleport
]

{ #category : #'instance creation' }
InterVMChannel class >> headless [
	|o|
	o := super new.
	o teleport headless process.
	^o teleport
]

{ #category : #'instance creation' }
InterVMChannel class >> headless: memSize [
	|o|
	o := super new.
	o setMemSize: memSize.
	o teleport  process.
	^o teleport
]

{ #category : #'instance creation' }
InterVMChannel class >> methodByName: aName [
	[ ^self methodNamed: aName ] on: Error do: [ ^ self superclass methodByName: aName ] 
]

{ #category : #'instance creation' }
InterVMChannel class >> new [
	^self headless
]

{ #category : #'instance creation' }
InterVMChannel class >> new: memSize [
	^self headless: memSize
]

{ #category : #'instance creation' }
InterVMChannel class >> slave [
	^ super new
]

{ #category : #initialization }
InterVMChannel >> initialize [
	portal := InterVMPortal new.
	portal << self.
	iostream :=  nil.
]

{ #category : #accessing }
InterVMChannel >> process [
	|val|
	[[ self iostream isOpen ] whileTrue: [ 
		self iostream atEnd ifFalse:[
			val := self iostream next.
			val class = MessageSend
				ifTrue:[
					val receiver: self.
					val value
				]
				ifFalse:[
					self processData: val	
				]
		]
	]] forkAt: Processor userBackgroundPriority 
]

{ #category : #accessing }
InterVMChannel >> processData:data [
	^self subclassResponsibility 
]
