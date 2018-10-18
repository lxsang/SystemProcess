Class {
	#name : #BaselineOfSystemProcess,
	#superclass : #BaselineOf,
	#category : #BaselineOfSystemProcess
}

{ #category : #baselines }
BaselineOfSystemProcess >> baseline: spec [
	<baseline>
spec for: #common do: [ 
	spec
		package: 'SystemProcess';
		group: 'default' with: #('SystemProcess')
]
]
