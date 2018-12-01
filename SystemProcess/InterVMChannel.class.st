Class {
	#name : #InterVMChannel,
	#superclass : #InterVMBaseTransport,
	#category : #SystemProcess
}

{ #category : #'instance creation' }
InterVMChannel class >> new [
	|o|
	o := super new.
	^ o teleport
]

{ #category : #'instance creation' }
InterVMChannel class >> slave [
	^ super new
]
