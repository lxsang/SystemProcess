Extension { #name : #Integer }

{ #category : #'*SystemProcess' }
Integer >> Kb [
	^ self*1024
]

{ #category : #'*SystemProcess' }
Integer >> Mb [
	^ (self Kb)*1024
]
