Extension { #name : #RPackageTag }

{ #category : #'*Pragmatic' }
RPackageTag >> definedClassesPragmatic [

	^ package definedClasses select: [ :a | classNames includes: a name ]
]
