Class {
	#name : #InterVMTest,
	#superclass : #InterVMBaseModule,
	#instVars : [
		'sho'
	],
	#category : #SystemProcess
}

{ #category : #initialization }
InterVMTest >> initialize [
	super initialize.
	sho := SharedMemStream on:'/test_shared'.
	sho open.
]

{ #category : #'as yet unclassified' }
InterVMTest >> openShared [
	|o|
	o := SharedMemStream on:'/test_shared'.
	o open.
	o close
]

{ #category : #writing }
InterVMTest >> readBuff [
	sho read inspect.
	"o close"
]

{ #category : #writing }
InterVMTest >> writeBuf [
	sho write: 'Hello darkness my old friend'
]
