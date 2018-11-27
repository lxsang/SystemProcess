Class {
	#name : #InterVMChannel,
	#superclass : #InterVMBaseTransport,
	#category : #SystemProcess
}

{ #category : #'instance creation' }
InterVMChannel >> initialize [
	super initialize.
	mainstream := true
]
