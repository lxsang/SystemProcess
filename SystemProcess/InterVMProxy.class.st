Class {
	#name : #InterVMProxy,
	#superclass : #Object,
	#instVars : [
		'proxy'
	],
	#category : #SystemProcess
}

{ #category : #'image, changes name' }
InterVMProxy class >> imageFile [
	^Smalltalk imageFile asFileReference 
]

{ #category : #'instance creation' }
InterVMProxy class >> on: aRosProxy [
	^self new on:aRosProxy; yourself
]

{ #category : #vm }
InterVMProxy class >> vmBin [
	"Smalltalk os isMacOS ifTrue: [ ^Smalltalk vmDirectory asFileReference / 'Pharo.app'/'Contents'/'MacOS'/'Pharo' ].
	^Smalltalk vmDirectory asFileReference / 'pharo'"
	^ Smalltalk vmBinary asFileReference 
]

{ #category : #'instance creation' }
InterVMProxy >> on: rosProxy [
	self proxy: rosProxy 
]

{ #category : #accessing }
InterVMProxy >> proxy [
	^ proxy
]

{ #category : #accessing }
InterVMProxy >> proxy: anObject [
	proxy := anObject
]

{ #category : #running }
InterVMProxy >> run: aMethod of: aClass [
	^ self run: aMethod of:aClass headless: false 
]

{ #category : #running }
InterVMProxy >> run: aMethod of: aClass headless: headless [
	|args pname process|
	process := SystemProcess new.
	pname := '/',aMethod,'_',Time now asNanoSeconds asString.
	args := OrderedCollection new.
	args add: self class vmBin pathString.
	headless ifTrue:[ 
		Smalltalk os isMacOS 
			ifTrue:[ args add: '--headless']
			ifFalse:[ args add: '-vm-display-null']].
	Smalltalk os isMacOS ifFalse:[
		args add: '-vm-sound-null'].
	args add: self class imageFile pathString.
	args add: 'eval'.
	args add: '--no-quit'.
	args add: aClass asString, ' slave iostream: ((SharedMemStream on:''',pname,''' process:nil) open:true; yourself);',aMethod,'.'.
	process watch: false.
	process shellCommand: args.
	^ SharedMemStream on: pname process: process.
]
