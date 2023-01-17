/*
 * generated by Xtext 2.10.0
 */
package com.regnosys.rosetta.formatting2

import org.eclipse.xtext.formatting2.AbstractFormatter2
import org.eclipse.xtext.formatting2.IFormattableDocument
import com.regnosys.rosetta.rosetta.expression.RosettaUnaryOperation

class RosettaFormatter extends AbstractFormatter2 {	
	def dispatch void format(RosettaUnaryOperation expr, extension IFormattableDocument document) {		
		expr.formatConditionally(
			[extension doc |
				set(
					expr.argument.nextHiddenRegion,
					expr.nextHiddenRegion,
					[indent]
				)
			]
		)
	}
}
