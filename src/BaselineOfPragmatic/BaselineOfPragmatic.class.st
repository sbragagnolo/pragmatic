Class {
	#name : #BaselineOfPragmatic,
	#superclass : #BaselineOf,
	#category : #BaselineOfPragmatic
}

{ #category : #baselines }
BaselineOfPragmatic >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ spec blessing: #baseline.
			spec package: #Pragmatic ]
]
