Class {
	#name : #InterVMPortal,
	#superclass : #InterVMTeleport,
	#instVars : [
		'iostream'
	],
	#category : #SystemProcess
}

{ #category : #accessing }
InterVMPortal >> close [
	super close.
	iostream ifNotNil: [ 
		iostream terminate
	]
]

{ #category : #'reflective operations' }
InterVMPortal >> doesNotUnderstand: msg [
	iostream ifNil: [ 
		self iostream: (super doesNotUnderstand: msg).
		self iostream ifNil: [ ^self ].
		self iostream open.
		^self].
	(target respondsTo: msg selector) ifTrue:[
		^ iostream nextPut: (MessageSend receiver: nil selector: msg selector  arguments: msg arguments )
	].
	^ self error: 'Message not found: ', msg selector.
]

{ #category : #accessing }
InterVMPortal >> iostream [
	^ iostream
]

{ #category : #accessing }
InterVMPortal >> iostream: anObject [
	iostream := anObject
]
