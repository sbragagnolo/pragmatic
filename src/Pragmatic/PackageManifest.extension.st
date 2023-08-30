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
PackageManifest class >> documentSending: aSelector titled: aTitle [

	^ String streamContents: [ :stream | 
		  PRGWriter markup
			  writeDocumentation: self
			  sending: aSelector
			  into: stream
			  titled: aTitle ]
]

{ #category : #'*Pragmatic' }
PackageManifest class >> readme [

	^ String streamContents: [ :stream |
		  PRGWriter markup writeReadme: self into: stream ]
]

{ #category : #'*Pragmatic' }
PackageManifest class >> tags: anArray [

	^ self package classTags select: [ :ct | anArray includes: ct name ]
]
