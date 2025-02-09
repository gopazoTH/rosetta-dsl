package com.regnosys.rosetta.ide.inlayhints;

import org.eclipse.lsp4j.InlayHint;
import org.eclipse.xtext.ide.server.Document;
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.util.CancelIndicator;

public interface IInlayHintsResolver {
	InlayHint resolveInlayHint(Document document, XtextResource resource, InlayHint unresolved, CancelIndicator cancelIndicator);
}
