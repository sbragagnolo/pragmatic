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
PRGWriter >> writeClass: aClass on: aStream onDepth: aLevel [
	| methods examples |
	aStream nextPutAll: (formater titleFor: aClass name level: aLevel).
	aStream nextPutAll: formater separator.
	aStream nextPutAll: (formater classCommentFor: aClass comment level: aLevel).
	aStream nextPutAll: formater separator.
	aStream nextPutAll: formater separator.
	examples := Pragma allNamed: #example from: aClass class to: aClass class.
	examples
		ifNotEmpty: [ aStream nextPutAll: (formater subtitleFor: 'Examples: ' level: aLevel).
			aStream nextPutAll: formater separator.
			examples do: [ :p | aStream nextPutAll: (formater examplePragmaMethod: p level: aLevel) ].
			aStream nextPutAll: formater separator ].
	aClass instanceVariables
		ifNotEmpty: [ aStream nextPutAll: (formater subtitleFor: 'Properties' level: aLevel).
			aStream nextPutAll: formater separator.
			aClass
				instanceVariableNamesDo: [ :i | 
					aStream nextPutAll: (formater propertyCommentFor: i atClass: aClass level: aLevel).
					aStream nextPutAll: formater separator ].
			aStream nextPutAll: formater separator ].
	methods := (Pragma allNamed: #doc: from: aClass to: aClass) asOrderedCollection.
	methods
		ifNotEmpty: [ aStream nextPutAll: (formater subtitleFor: 'Methods' level: aLevel).
			aStream nextPutAll: formater separator.
			methods do: [ :p | self writePragmaMethod: p on: aStream level: aLevel + 2 ].
			aStream nextPutAll: formater separator ].
	methods := (Pragma allNamed: #doc: from: aClass class to: aClass class) asOrderedCollection.
	methods
		ifNotEmpty: [ aStream nextPutAll: (formater subtitleFor: 'Class Methods' level: aLevel).
			aStream nextPutAll: formater separator.
			methods do: [ :p | self writePragmaMethod: p on: aStream level: aLevel + 2 ].
			aStream nextPutAll: formater separator ]
]

{ #category : #writing }
PRGWriter >> writePackage: aPackage on: aStream onDepth: aLevel [
	aStream nextPutAll: (formater titleFor: aPackage name, ' - Generated Doc' level: aLevel).
	aStream nextPutAll: formater separator.
	(aPackage classes select: [ :c | c superclass = PackageManifest ])
		do: [ :manifest | 
			aStream nextPutAll: (formater subtitleFor: 'Manifast' level: aLevel).
			aStream nextPutAll: formater separator.
			aStream nextPutAll: (formater classCommentFor: manifest comment level: aLevel).
			aStream nextPutAll: (formater subtitleFor: 'Project Examples' level: aLevel).
			aStream nextPutAll: formater separator.
			(Pragma allNamed: #example from: manifest class to: manifest class) do: [ :p | aStream nextPutAll: (formater examplePragmaMethod: p level: aLevel) ].
			aStream nextPutAll: formater separator.
			aStream nextPutAll: formater separator ].
	(aPackage definedClasses asSortedCollection: [ :a :b | a name < b name ])
		do: [ :c | 
			(Pragma allNamed: #doc: from: c to: c) , (Pragma allNamed: #doc: from: c class to: c class)
				ifNotEmpty: [ self writeClass: c on: aStream onDepth: aLevel + 1.
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
