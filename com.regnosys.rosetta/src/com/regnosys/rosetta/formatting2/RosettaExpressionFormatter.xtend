package com.regnosys.rosetta.formatting2

/*
 * For info on the formatter API, see https://www.slideshare.net/meysholdt/xtexts-new-formatter-api.
 */

import org.eclipse.xtext.formatting2.AbstractFormatter2
import org.eclipse.xtext.formatting2.IFormattableDocument
import org.eclipse.xtext.formatting2.FormatterRequest
import com.regnosys.rosetta.rosetta.expression.RosettaExistsExpression

class RosettaExpressionFormatter extends AbstractFormatter2 {
		
	override void initialize(FormatterRequest request) {
		super.initialize(request)
	}
	
	override format(Object obj, IFormattableDocument document) {
		switch (obj) {
			RosettaExistsExpression: formatExpression(obj, document)
			default: throw new UnsupportedOperationException('''«RosettaExpressionFormatter» does not support formatting «obj».''')
		}
	}
	
	def void formatExpression(RosettaExistsExpression expr, extension IFormattableDocument document) {
		val region = expr.regionForEObject.merge(expr.nextHiddenRegion)
		formatConditionally(region.offset, region.getLength(),
			[doc | // case: short operation
				val extension singleLineDoc = doc.requireFitsInLine
				if (expr.argument !== null) {
					expr.argument.nextHiddenRegion
						.set[oneSpace]
					expr.argument.formatExpression(singleLineDoc)
				}
			],
			[extension doc | // case: long operation
				formatUnaryOperationMultiLine(expr, doc)
			]
		)
	}
	
	private def void formatUnaryOperationMultiLine(RosettaExistsExpression expr, extension IFormattableDocument document) {
		if (expr.argument !== null) {
			val afterArgument = expr.argument.nextHiddenRegion
			afterArgument
				.set[newLine]
			set(
				afterArgument,
				expr.nextHiddenRegion,
				[indent]
			)
			expr.argument.formatExpression(document)
		}
	}
}