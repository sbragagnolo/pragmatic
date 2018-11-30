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
PRGWriter >> write: aClass on: aStream onDepth: aLevel [
	| methods |
	aStream nextPutAll: (formater titleFor: aClass name level: aLevel).
	aStream nextPutAll: formater separator.
	aStream nextPutAll: (formater classCommentFor: aClass comment level: aLevel).
	aStream nextPutAll: formater separator.
	aStream nextPutAll: formater separator.
	aStream nextPutAll: (formater subtitleFor: 'Properties' level: aLevel).
	aStream nextPutAll: formater separator.
	aClass
		instanceVariableNamesDo: [ :i | 
			aStream nextPutAll: (formater propertyCommentFor: i atClass: aClass level: aLevel).
			aStream nextPutAll: formater separator ].
	aStream nextPutAll: formater separator.
	aStream nextPutAll: (formater subtitleFor: 'Methods' level: aLevel).
	aStream nextPutAll: formater separator.
	methods := (Pragma allNamed: #doc: from: aClass to: aClass) asOrderedCollection.
	methods do: [ :p | self writePragmaMethod: p on: aStream level: aLevel + 2 ].
	aStream nextPutAll: formater separator.
	aStream nextPutAll: (formater subtitleFor: 'Class Methods' level: aLevel).
	aStream nextPutAll: formater separator.
	methods := (Pragma allNamed: #doc: from: aClass class to: aClass class) asOrderedCollection.
	methods do: [ :p | self writePragmaMethod: p on: aStream level: aLevel + 2 ]
]

{ #category : #writing }
PRGWriter >> writePragmaMethod: aPragma on: aWriteStream level: anInteger [
	aWriteStream nextPutAll: (formater titleFor: aPragma method sourceCode lines first level: anInteger).
	aWriteStream nextPutAll: formater separator.
	aWriteStream nextPutAll: (formater methodComment: aPragma arguments first level: anInteger).
	aWriteStream nextPutAll: formater separator.
	aWriteStream nextPutAll: (formater code: aPragma method sourceCode level: anInteger).
	aWriteStream nextPutAll: formater separator.
]
