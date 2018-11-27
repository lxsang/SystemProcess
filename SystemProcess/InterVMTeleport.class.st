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
	stream := proxy run: sel of: target class headless: headless. 
	target mainstream ifTrue:[
		target iostream ifNotNil: [ target iostream close ].
		stream open.
		target iostream: stream ].
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
