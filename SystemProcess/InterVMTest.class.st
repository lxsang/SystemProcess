"
usage:

o := InterVMTest new.
stream := o calculate.
stream open.
i := 0.
	[[ stream isOpen ] whileTrue: [ 
		stream nextPut: i.
		stream atEnd ifFalse:[
			Transcript show: 'get: ', stream next asString; cr.	
		].
		i := i + 1.
	]] forkAt: Processor userBackgroundPriority.
stream close.
o close.
"
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
