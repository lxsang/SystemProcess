Class {
	#name : #InterVMAvatarObject,
	#superclass : #InterVMBaseTransport,
	#category : #SystemProcess
}

{ #category : #'instance creation' }
InterVMAvatarObject class >> new [
	|o|
	o := super new.
	o teleport process.
	^o teleport
]

{ #category : #'instance creation' }
InterVMAvatarObject class >> slave [
	^ super new
]

{ #category : #initialization }
InterVMAvatarObject >> initialize [
	portal := InterVMPortal new.
	portal << self.
	iostream :=  nil.
]

{ #category : #accessing }
InterVMAvatarObject >> process [
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
InterVMAvatarObject >> processData:data [
	^self subclassResponsibility 
]
