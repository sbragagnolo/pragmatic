Extension { #name : #PackageManifest }

{ #category : #'*Pragmatic' }
PackageManifest class >> apiDocumentation [

	^ String streamContents: [ :stream |
		  PRGWriter markup writeApi: self into: stream ]
]

{ #category : #'*Pragmatic' }
PackageManifest class >> apiPackages [

	^ { self package }
]

{ #category : #'*Pragmatic' }
PackageManifest class >> readme [

	^ String streamContents: [ :stream |
		  PRGWriter markup writeReadme: self into: stream ]
]
