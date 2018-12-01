Class {
	#name : #InterVMProxy,
	#superclass : #Object,
	#instVars : [
		'proxy',
		'process'
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
	Smalltalk os isMacOS ifTrue: [ ^Smalltalk vmDirectory asFileReference / 'Pharo.app'/'Contents'/'MacOS'/'Pharo' ].
	^Smalltalk vmDirectory asFileReference / 'pharo'
]

{ #category : #'initialize-release' }
InterVMProxy >> close [
	process ifNil: [ ^self ].
	process cleanup.
	process := nil.
]

{ #category : #initialization }
InterVMProxy >> initialize [
	process := SystemProcess new.
	"proxy := PhaROSPackage new."
]

{ #category : #'instance creation' }
InterVMProxy >> on: rosProxy [
	self proxy: rosProxy 
]

{ #category : #accessing }
InterVMProxy >> process [
	^ process
]

{ #category : #accessing }
InterVMProxy >> process: anObject [
	process := anObject
]

{ #category : #accessing }
InterVMProxy >> proxy [
	^ proxy
]

{ #category : #accessing }
InterVMProxy >> proxy: anObject [
	proxy := anObject
]

{ #category : #'as yet unclassified' }
InterVMProxy >> resultFrom: topic ofType: type do: aBlock [
	"subcriber to a topic"
]

{ #category : #'as yet unclassified' }
InterVMProxy >> run: aMethod of: aClass [
	^ self run: aMethod of:aClass headless: false 
]

{ #category : #'as yet unclassified' }
InterVMProxy >> run: aMethod of: aClass headless: headless [
	|args pname|
	process ifNil:[^self].
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
	args add: aClass asString, ' new iostream: ((SharedMemStream on:''',pname,''') open:true; yourself);',aMethod,'.'.
	self process watch: false.
	self process shellCommand: args.
	^ SharedMemStream on: pname.
]
