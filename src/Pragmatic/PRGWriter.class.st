Class {
	#name : #PRGWriter,
	#superclass : #Object,
	#instVars : [
		'formater'
	],
	#category : #Pragmatic
}

{ #category : #creation }
PRGWriter class >> markup [
	^ self new
		formater: PRGMarkdownFormatter new;
		yourself
]

{ #category : #accessing }
PRGWriter >> formater: aPRGMarkdownFormatter [ 
	formater := aPRGMarkdownFormatter
]

{ #category : #writing }
PRGWriter >> hasToBeDocumented: c [
	^ ((Pragma allNamed: #doc: from: c to: c) isEmpty
		and: [ (Pragma allNamed: #doc: from: c class to: c class) isEmpty
				and: [ (Pragma allNamed: #doc from: c class to: c class) isEmpty and: [ (Pragma allNamed: #doc from: c class to: c class) isEmpty ] ] ]) not
]

{ #category : #private }
PRGWriter >> processPragmaDocOn: aClass titled: aTitle level: aLevel stream: aStream [
	| methods |
	methods := (Pragma allNamed: #doc: from: aClass to: aClass) asOrderedCollection.
	methods
		ifNotEmpty: [ aStream nextPutAll: (formater subtitleFor: aTitle level: aLevel).
			aStream nextPutAll: formater separator.
			methods do: [ :p | self writePragmaMethod: p on: aStream level: aLevel + 2 ].
			aStream nextPutAll: formater separator ]
]

{ #category : #private }
PRGWriter >> processPragmaDocShortOn: aClass titled: aTitle level: aLevel stream: aStream [
	| methods |
	methods := (Pragma allNamed: #doc from: aClass to: aClass) asOrderedCollection.
	methods
		ifNotEmpty: [ aStream nextPutAll: (formater subtitleFor: aTitle level: aLevel).
			aStream nextPutAll: formater separator.
			methods do: [ :p | self writeShortPragmaMethod: p on: aStream level: aLevel + 2 ].
			aStream nextPutAll: formater separator ]
]

{ #category : #private }
PRGWriter >> processPragmaExampleOn: aClass titled: aTitle level: aLevel stream: aStream [
	| examples |
	examples := Pragma allNamed: #example from: aClass class to: aClass class.
	examples
		ifNotEmpty: [ aStream nextPutAll: (formater subtitleFor: aTitle level: aLevel).
			aStream nextPutAll: formater separator.
			examples do: [ :p | aStream nextPutAll: (formater examplePragmaMethod: p level: aLevel) ].
			aStream nextPutAll: formater separator ]
]

{ #category : #private }
PRGWriter >> processPropertiesOn: aClass level: aLevel stream: aStream [
	aClass instanceVariables
		ifNotEmpty: [ aStream nextPutAll: (formater subtitleFor: 'Properties' level: aLevel).
			aStream nextPutAll: formater separator.
			aClass
				instanceVariableNamesDo: [ :i | 
					aStream nextPutAll: (formater propertyCommentFor: i atClass: aClass level: aLevel).
					aStream nextPutAll: formater separator ].
			aStream nextPutAll: formater separator ]
]

{ #category : #writing }
PRGWriter >> writeClass: aClass on: aStream onDepth: aLevel [
	| examples |
	aStream nextPutAll: (formater titleFor: aClass name level: aLevel).
	aStream nextPutAll: formater separator.
	aStream nextPutAll: (formater classCommentFor: aClass comment level: aLevel).
	aStream nextPutAll: formater separator.
	aStream nextPutAll: formater separator.
	self
		processPragmaExampleOn: aClass
		titled: 'Examples'
		level: aLevel
		stream: aStream.
	examples := Pragma allNamed: #example from: aClass class to: aClass class.
	examples
		ifNotEmpty: [ aStream nextPutAll: (formater subtitleFor: 'Examples: ' level: aLevel).
			aStream nextPutAll: formater separator.
			examples do: [ :p | aStream nextPutAll: (formater examplePragmaMethod: p level: aLevel) ].
			aStream nextPutAll: formater separator ].
	self processPropertiesOn: aClass level: aLevel stream: aStream.
	self
		processPragmaDocOn: aClass
		titled: 'Methods'
		level: aLevel
		stream: aStream.
	self processPragmaDocShortOn: aClass titled: 'Methods code' level: aLevel stream: aStream.
	self
		processPragmaDocOn: aClass class
		titled: 'Class Methods'
		level: aLevel
		stream: aStream.
	self processPragmaDocShortOn: aClass class titled: 'Class Methods code' level: aLevel stream: aStream.
]

{ #category : #writing }
PRGWriter >> writePackage: aPackage on: aStream onDepth: aLevel [
	aStream nextPutAll: (formater titleFor: aPackage name , ' - Generated Doc' level: aLevel).
	aStream nextPutAll: formater separator.
	(aPackage classes select: [ :c | c superclass = PackageManifest ])
		do: [ :manifest | 
			aStream nextPutAll: (formater subtitleFor: 'Manifest' level: aLevel).
			aStream nextPutAll: formater separator.
			aStream nextPutAll: (formater classCommentFor: manifest comment level: aLevel).
			self
				processPragmaExampleOn: manifest
				titled: 'Project Examples'
				level: aLevel
				stream: aStream.
			aStream nextPutAll: formater separator.
			aStream nextPutAll: formater separator ].
	(aPackage definedClasses asSortedCollection: [ :a :b | a name < b name ])
		do: [ :c | 
			(self hasToBeDocumented: c)
				ifTrue: [ self writeClass: c on: aStream onDepth: aLevel + 1.
					aStream nextPutAll: formater separator ] ]
]

{ #category : #writing }
PRGWriter >> writePragmaMethod: aPragma on: aWriteStream level: anInteger [
	aWriteStream nextPutAll: (formater titleFor:aPragma method methodClass  name, '>>', aPragma method sourceCode lines first level: anInteger).
	aWriteStream nextPutAll: formater separator.
	aWriteStream nextPutAll: (formater methodComment: aPragma arguments first level: anInteger).
	aWriteStream nextPutAll: formater separator.
	aWriteStream nextPutAll: formater separator.
	"aWriteStream nextPutAll: (formater code: aPragma method sourceCode level: anInteger).
	aWriteStream nextPutAll: formater separator."
]

{ #category : #writing }
PRGWriter >> writeShortPragmaMethod: aPragma on: aWriteStream level: anInteger [
	aWriteStream nextPutAll: (formater titleFor: aPragma method methodClass name , '>>' , aPragma method sourceCode lines first level: anInteger).
	aWriteStream nextPutAll: formater separator.
	aWriteStream nextPutAll: (formater code: aPragma method sourceCode level: anInteger).
	aWriteStream nextPutAll: formater separator
]
