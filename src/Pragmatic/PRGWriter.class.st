"
Writes documentation analyzed from pragmas by using a formatter.
"
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

{ #category : #'as yet unclassified' }
PRGWriter >> pragmas: aString for: aClass [

	| pragmas |
	pragmas := Pragma allNamed: aString from: aClass to: aClass.


	pragmas := pragmas sort: [ :a | a method protocol ] asSortFunction
		           , [ :a | a method selector ] asSortFunction.
	^ pragmas asOrderedCollection
]

{ #category : #private }
PRGWriter >> processPragmaDocOn: aClass titled: aTitle level: aLevel stream: aStream [
	| methods |

	methods :=self pragmas: #doc: for: aClass.
	methods
		ifNotEmpty: [ aStream nextPutAll: (formater subtitleFor: aTitle level: aLevel).
			aStream nextPutAll: formater separator.
			methods do: [ :p | self writePragmaMethod: p on: aStream level: aLevel + 2 ].
			aStream nextPutAll: formater separator ]
]

{ #category : #private }
PRGWriter >> processPragmaDocShortOn: aClass titled: aTitle level: aLevel stream: aStream [
	| methods |
	methods := self pragmas: #doc for: aClass.
	methods
		ifNotEmpty: [ aStream nextPutAll: (formater subtitleFor: aTitle level: aLevel).
			aStream nextPutAll: formater separator.
			methods do: [ :p | self writeShortPragmaMethod: p on: aStream level: aLevel + 2 ].
			aStream nextPutAll: formater separator ]
]

{ #category : #private }
PRGWriter >> processPragmaExampleOn: aClass titled: aTitle level: aLevel stream: aStream [

	| examples |

	examples := self pragmas: #example for: aClass class.
	examples ifNotEmpty: [ 
		aStream nextPutAll: (formater subtitleFor: aTitle level: aLevel).
		aStream nextPutAll: formater separator.
		examples do: [ :p | 
			aStream nextPutAll: (formater examplePragmaMethod: p level: aLevel) ].
		aStream nextPutAll: formater separator ]
]

{ #category : #private }
PRGWriter >> processPragmaLoadOn: aClass titled: aTitle level: aLevel stream: aStream [

	| examples |
	examples := self pragmas: #load for: aClass.
	examples ifNotEmpty: [ 
		aStream nextPutAll: (formater subtitleFor: aTitle level: aLevel).
		aStream nextPutAll: formater separator.
		examples do: [ :p | 
			aStream nextPutAll: (formater loadPragmaMethod: p level: aLevel) ].
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
PRGWriter >> writeApi: aManifest into: stream [

	^ self
		  writeDocumentation: aManifest
		  sending: #apiPackages
		  into: stream
		  titled: #API
]

{ #category : #writing }
PRGWriter >> writeClass: aClass on: aStream onDepth: aLevel [

	| examples |
	aStream nextPutAll: (formater titleFor: aClass name level: aLevel).
	aStream nextPutAll: formater separator.
	aClass holdsPackageDocumentation ifFalse: [ 
		aStream nextPutAll:
			(formater classCommentFor: aClass comment level: aLevel).
		aStream nextPutAll: formater separator.
		aStream nextPutAll: formater separator ].

	self
		processPragmaExampleOn: aClass
		titled: 'Examples'
		level: aLevel
		stream: aStream.
	examples := Pragma
		            allNamed: #example
		            from: aClass class
		            to: aClass class.
	examples ifNotEmpty: [ 
		aStream nextPutAll:
			(formater subtitleFor: 'Examples: ' level: aLevel).
		aStream nextPutAll: formater separator.
		examples do: [ :p | 
			aStream nextPutAll: (formater examplePragmaMethod: p level: aLevel) ].
		aStream nextPutAll: formater separator ].
	self processPropertiesOn: aClass level: aLevel stream: aStream.
	self
		processPragmaDocOn: aClass
		titled: 'Methods'
		level: aLevel
		stream: aStream.
	self
		processPragmaDocShortOn: aClass
		titled: 'Methods code'
		level: aLevel
		stream: aStream.
	self
		processPragmaDocOn: aClass class
		titled: 'Class Methods'
		level: aLevel
		stream: aStream.
	self
		processPragmaDocShortOn: aClass class
		titled: 'Class Methods code'
		level: aLevel
		stream: aStream
]

{ #category : #writing }
PRGWriter >> writeDocumentation: aManifest sending: aSymbol into: aStream titled: aTitle [

	aStream nextPutAll:
		(formater titleFor: aManifest package name , ' - ' , aTitle level: 1).
	aStream nextPutAll: formater separator.
	(aManifest perform: aSymbol) do: [ :package |
		self writePackage: package on: aStream onDepth: 1 ].
	^ aStream
]

{ #category : #writing }
PRGWriter >> writePackage: aPackage on: aStream onDepth: aLevel [
	| allClasses |

	allClasses := (aPackage definedClassesPragmatic asSortedCollection: [ :a :b | a name < b name ]).
	allClasses select: [: a | a holdsPackageDocumentation ] thenDo: [: c | self writePackageComment: c on: aStream].
	allClasses
		do: [ :c | 
			(self hasToBeDocumented: c)
				ifTrue: [ self writeClass: c on: aStream onDepth: aLevel + 1.
					aStream nextPutAll: formater separator ] ]
]

{ #category : #writing }
PRGWriter >> writePackageComment: aClass on: aStream [

	aStream nextPutAll:
		(formater titleFor: aClass package name , '  ' level: 1).
	aStream nextPutAll:
		(formater classCommentFor: aClass comment level: 1).
	aStream nextPutAll: formater separator
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
PRGWriter >> writeReadme: aManifest into: aStream [

	aStream nextPutAll:
		(formater titleFor: aManifest package name , ' - ReadMe' level: 1).
	aStream nextPutAll: formater separator.

	aStream nextPutAll: (formater subtitleFor: 'Manifest' level: 1).
	aStream nextPutAll: formater separator.
	aStream nextPutAll:
		(formater classCommentFor: aManifest comment level: 1).
	self
		processPragmaLoadOn: aManifest
		titled: 'Load'
		level: 1
		stream: aStream.
	self
		processPragmaExampleOn: aManifest
		titled: 'Project Examples'
		level: 1
		stream: aStream.
	aStream nextPutAll: formater separator.
	aStream nextPutAll: formater separator.
	^ aStream
]

{ #category : #writing }
PRGWriter >> writeShortPragmaMethod: aPragma on: aWriteStream level: anInteger [
	aWriteStream nextPutAll: (formater titleFor: aPragma method methodClass name , '>>' , aPragma method sourceCode lines first level: anInteger).
	aWriteStream nextPutAll: formater separator.
	aWriteStream nextPutAll: (formater code: aPragma method sourceCode level: anInteger).
	aWriteStream nextPutAll: formater separator
]
