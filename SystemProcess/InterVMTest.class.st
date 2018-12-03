"
usage:
stream := InterVMTest new process.
stream open.
i := 0.
	[[ stream isOpen ] whileTrue: [ 
		stream nextPut: i.
		stream atEnd ifFalse:[
			Transcript show: 'get: ', stream next asString; cr.	
		].
		i := i + 1.
	]] forkAt: Processor userBackgroundPriority.
stream terminate
"
Class {
	#name : #InterVMTest,
	#superclass : #InterVMSlave,
	#category : #SystemProcess
}

{ #category : #accessing }
InterVMTest >> processData: data [
	|val|
	Transcript show:'Get: ', data asString;cr.
	val := data*100.
	self iostream nextPut: val
]
