Class {
	#name : #InterVMTest,
	#superclass : #InterVMChannel,
	#category : #SystemProcess
}

{ #category : #'as yet unclassified' }
InterVMTest >> calculate [
	|val|
	[[ self iostream isOpen ] whileTrue: [ 
		self iostream atEnd ifFalse:[
			val := self iostream next.
			Transcript show:'Get: ', val asString;cr.
			val := val*100.
			self iostream nextPut: val
		]
	]] forkAt: Processor userBackgroundPriority 
]

{ #category : #accessing }
InterVMTest >> process [
	|i|
	"teleport to get the stream"
	i := 1.
	self teleport calculate.
	[[ self iostream isOpen ] whileTrue: [ 
		self iostream nextPut: i.
		self iostream atEnd ifFalse:[
			Transcript show: 'get: ', self iostream next asString; cr.	
		].
		i := i + 1.
	]] forkAt: Processor userBackgroundPriority  
	
]
