"
usage:
portal := InterVMTest new.

[[ portal iostream isOpen ] whileTrue: [ 
		portal iostream atEnd ifFalse:[
			Transcript show: 'get: ', portal iostream next asString; cr.	
		].
	]] forkAt: Processor userBackgroundPriority.
portal processData: 1000.
portal close
"
Class {
	#name : #InterVMTest,
	#superclass : #InterVMAvatarObject,
	#category : #SystemProcess
}

{ #category : #accessing }
InterVMTest >> processData: data [
	|val|
	Transcript show:'Get: ', data asString;cr.
	val := data*100.
	self iostream nextPut: val
]
