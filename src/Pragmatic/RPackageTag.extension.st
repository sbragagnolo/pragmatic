Extension { #name : #RPackageTag }

{ #category : #'*Pragmatic' }
RPackageTag >> definedClasses [

	^ package definedClasses select: [ :a | classNames includes: a name ]
]
