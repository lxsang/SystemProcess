Class {
	#name : #InterVMBaseTransport,
	#superclass : #Object,
	#instVars : [
		'portal',
		'iostream',
		'mainstream'
	],
	#category : #SystemProcess
}

{ #category : #'instance creation' }
InterVMBaseTransport class >> on:aProxy [
	^self new on:aProxy; yourself
]

{ #category : #accessing }
InterVMBaseTransport >> closePortal [
	self teleport __close
]

{ #category : #initialization }
InterVMBaseTransport >> initialize [
	portal := InterVMTeleport new.
	portal << self.
	iostream := SharedQueue new.
	mainstream := false
]

{ #category : #accessing }
InterVMBaseTransport >> iostream [
	^ iostream
]

{ #category : #accessing }
InterVMBaseTransport >> iostream: anObject [
	iostream := anObject
]

{ #category : #accessing }
InterVMBaseTransport >> mainstream [
	^ mainstream
]

{ #category : #accessing }
InterVMBaseTransport >> mainstream: anObject [
	mainstream := anObject
]

{ #category : #accessing }
InterVMBaseTransport >> on: proxy [
	self proxy: proxy 
]

{ #category : #accessing }
InterVMBaseTransport >> proxy: p [
	portal __proxy: p
]

{ #category : #accessing }
InterVMBaseTransport >> teleport [
	^portal
]
