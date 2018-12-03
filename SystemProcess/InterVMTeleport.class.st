Class {
	#name : #InterVMTeleport,
	#superclass : #Object,
	#instVars : [
		'target',
		'proxy',
		'headless'
	],
	#category : #SystemProcess
}

{ #category : #accessing }
InterVMTeleport >> << anObject [
	target := anObject 
]

{ #category : #accessing }
InterVMTeleport >> __proxy: p [
	proxy := p.
]

{ #category : #accessing }
InterVMTeleport >> close [
	target ifNotNil: [
		target iostream ifNotNil: [ target iostream close ].
	]
]

{ #category : #'reflective operations' }
InterVMTeleport >> doesNotUnderstand: msg [
	|sel stream|
	target ifNil: [ ^nil ].
	sel := msg selector.
	(target respondsTo: sel) ifFalse:[^target doesNotUnderstand: msg]. 
	stream := proxy run: sel asString of: target class headless: headless. 
	^stream
]

{ #category : #accessing }
InterVMTeleport >> headless [
	headless := true.
	^self
]

{ #category : #initialization }
InterVMTeleport >> initialize [
	proxy := InterVMProxy new.
	headless := false
]
