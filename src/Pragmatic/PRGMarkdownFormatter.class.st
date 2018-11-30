Class {
	#name : #PRGMarkdownFormatter,
	#superclass : #Object,
	#category : #Pragmatic
}

{ #category : #'as yet unclassified' }
PRGMarkdownFormatter >> classCommentFor: aClassComment level: alevel [
	^ self sanitize: aClassComment
]

{ #category : #writing }
PRGMarkdownFormatter >> code: aString level: anInteger [
	| stream pragmalessCode |
	stream := aString readStream.
	stream upToAll: '<doc:'.
	pragmalessCode := stream atEnd
		ifTrue: [ aString ]
		ifFalse: [ stream upToAll: '''>'.
			stream upToEnd ].
	^ self
		sanitize:
			('```smalltalk
{1}
{2}
```
'
				format:
					{aString lines first.
					pragmalessCode})
]

{ #category : #writing }
PRGMarkdownFormatter >> examplePragmaMethod: pragma level: aLevel [
	| stream pragmalessCode code |
	code := self newLine join: pragma method sourceCode lines allButFirst.
	stream := pragma method sourceCode readStream.
	stream upToAll: '<example>'.
	pragmalessCode := stream upToEnd.
	^ self
		sanitize:
			('```smalltalk
{1}
{2}
```
'
				format:
					{pragma method sourceCode lines first.
					pragmalessCode})
]

{ #category : #writing }
PRGMarkdownFormatter >> methodComment: aString level: anInteger [
	^ self sanitize: aString
]

{ #category : #'as yet unclassified' }
PRGMarkdownFormatter >> newLine [
	^ String lf
]

{ #category : #'as yet unclassified' }
PRGMarkdownFormatter >> propertyCommentFor: i atClass: aClass level: aLevel [
	^ self sanitize: i
]

{ #category : #'as yet unclassified' }
PRGMarkdownFormatter >> sanitize: aString [
	^ (aString copyReplaceAll: String cr with: String lf)
		copyReplaceAll: String lf , String lf
		with: String lf
]

{ #category : #'as yet unclassified' }
PRGMarkdownFormatter >> separator [
	^ String lf
]

{ #category : #'as yet unclassified' }
PRGMarkdownFormatter >> subtitleFor: aTitle level: aLevel [
	^ self titleFor: aTitle level: aLevel + 1
]

{ #category : #'as yet unclassified' }
PRGMarkdownFormatter >> titleFor: aTitle level: aLevel [
	^ self sanitize: ('' padLeftTo: aLevel with: $#) , ' ' , aTitle
]
