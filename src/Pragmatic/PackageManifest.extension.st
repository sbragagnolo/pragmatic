Extension { #name : #PackageManifest }

{ #category : #'*Pragmatic' }
PackageManifest class >> readme [
	^ String
		streamContents: [ :stream | PRGWriter markup writePackage: self package on: stream onDepth: 1 ]
]
