Class {
	#name : #InterVMBaseModule,
	#superclass : #Object,
	#instVars : [
		'portal',
		'iostream'
	],
	#category : #SystemProcess
}

{ #category : #'instance creation' }
InterVMBaseModule class >> on:aProxy [
	^self new on:aProxy; yourself
]

{ #category : #accessing }
InterVMBaseModule >> closePortal [
	self teleport __close
]

{ #category : #initialization }
InterVMBaseModule >> initialize [
	portal := InterVMTeleport new.
	portal << self.
	iostream := SharedQueue new.
]

{ #category : #accessing }
InterVMBaseModule >> iostream [
	^ iostream
]

{ #category : #accessing }
InterVMBaseModule >> iostream: anObject [
	iostream := anObject
]

{ #category : #accessing }
InterVMBaseModule >> on: proxy [
	self proxy: proxy 
]

{ #category : #accessing }
InterVMBaseModule >> proxy: p [
	portal __proxy: p
]

{ #category : #accessing }
InterVMBaseModule >> teleport [
	^portal
]
