Class {
	#name : #InterVMSlave,
	#superclass : #InterVMBaseTransport,
	#category : #SystemProcess
}

{ #category : #'instance creation' }
InterVMSlave class >> new [
	|o|
	o := super new.
	o teleport process.
	^o teleport
]

{ #category : #'instance creation' }
InterVMSlave class >> slave [
	^ super new
]

{ #category : #initialization }
InterVMSlave >> initialize [
	portal := InterVMPortal new.
	portal << self.
	iostream :=  nil.
]

{ #category : #accessing }
InterVMSlave >> process [
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
InterVMSlave >> processData:data [
	^self subclassResponsibility 
]
