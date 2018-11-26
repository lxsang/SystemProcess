Class {
	#name : #InterVMTeleport,
	#superclass : #Object,
	#instVars : [
		'target',
		'proxy'
	],
	#category : #SystemProcess
}

{ #category : #accessing }
InterVMTeleport >> << anObject [
	target := anObject 
]

{ #category : #accessing }
InterVMTeleport >> __close [
	proxy close
]

{ #category : #accessing }
InterVMTeleport >> __proxy: p [
	proxy := p.
]

{ #category : #'reflective operations' }
InterVMTeleport >> doesNotUnderstand: msg [
	|sel stream|
	target ifNil: [ ^self ].
	sel := msg selector asString.
	(target respondsTo: sel asSymbol) ifFalse:[^target doesNotUnderstand: msg]. 
	stream := proxy run: sel of: target class. 
	target mainstream ifTrue:[ target iostream: stream ].
	^stream
]

{ #category : #initialization }
InterVMTeleport >> initialize [
	proxy := InterVMProxy new.
]
