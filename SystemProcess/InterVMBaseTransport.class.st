Class {
	#name : #InterVMBaseTransport,
	#superclass : #Object,
	#instVars : [
		'portal',
		'iostream'
	],
	#category : #SystemProcess
}

{ #category : #'instance creation' }
InterVMBaseTransport class >> methodByName: aName [
	^self methodNamed: aName  
]

{ #category : #'instance creation' }
InterVMBaseTransport class >> on:aProxy [
	^self new on:aProxy; yourself
]

{ #category : #'initialize-release' }
InterVMBaseTransport >> close [
	self teleport close
]

{ #category : #initialization }
InterVMBaseTransport >> initialize [
	portal := InterVMTeleport new.
	portal << self.
	iostream :=  nil.
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
InterVMBaseTransport >> on: proxy [
	self proxy: proxy 
]

{ #category : #accessing }
InterVMBaseTransport >> proxy: p [
	portal __proxy: p
]

{ #category : #accessing }
InterVMBaseTransport >> setMemSize: memSize [
	portal __size: memSize 
]

{ #category : #accessing }
InterVMBaseTransport >> teleport [
	^portal
]
