Class {
	#name : #LibRt,
	#superclass : #FFILibrary,
	#category : #SystemProcess
}

{ #category : #'accessing platform' }
LibRt >> macModuleName [
	^self shouldBeImplemented 
]

{ #category : #'accessing platform' }
LibRt >> unixModuleName [
	^'librt.so.1'
]
