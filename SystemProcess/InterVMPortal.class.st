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
	|prags sel |
	target ifNil: [ ^nil ].
	sel := msg selector.
	(target respondsTo: sel) ifFalse:[^target doesNotUnderstand: msg].
	prags := (target class methodByName: sel) pragmas.
	prags isEmpty ifFalse:[
		prags first keyword = #master ifTrue:[
			^(MessageSend receiver: target selector: sel  arguments: msg arguments ) value
		]]. 
	iostream ifNil: [ 
		self iostream: (proxy run: sel asString of: target class headless: headless).
		self iostream open.
		target iostream: self iostream.
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
