Class {
	#name : #PRGMarkdownFormatter,
	#superclass : #Object,
	#category : #Pragmatic
}

{ #category : #'as yet unclassified' }
PRGMarkdownFormatter >> classCommentFor: aClassComment level: alevel [
	^ aClassComment
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
	^ '```smalltalk
{1}
{2}
```
'
		format:
			{aString lines first.
			pragmalessCode}
]

{ #category : #writing }
PRGMarkdownFormatter >> examplePragmaMethod: pragma level: aLevel [
	| stream pragmalessCode code |
	code := self newLine join: pragma method sourceCode lines allButFirst.
	stream := pragma method sourceCode readStream.
	stream upToAll: '<example>'.
	pragmalessCode := stream upToEnd.
	^ '```smalltalk
{1}
{2}
```
'
		format:
			{pragma method sourceCode lines first.
			pragmalessCode}
]

{ #category : #writing }
PRGMarkdownFormatter >> methodComment: aString level: anInteger [ 
	^ aString 
]

{ #category : #'as yet unclassified' }
PRGMarkdownFormatter >> newLine [
	^ String crlf
]

{ #category : #'as yet unclassified' }
PRGMarkdownFormatter >> propertyCommentFor: i atClass: aClass level: aLevel [
	^ i 
]

{ #category : #'as yet unclassified' }
PRGMarkdownFormatter >> separator [
	^ String crlf
]

{ #category : #'as yet unclassified' }
PRGMarkdownFormatter >> subtitleFor: aTitle level: aLevel [
	^ self titleFor: aTitle level: aLevel + 1
]

{ #category : #'as yet unclassified' }
PRGMarkdownFormatter >> titleFor: aTitle level: aLevel [
	^ ('' padLeftTo: aLevel with: $#) , aTitle
]
