# xslide Emacs mode for XSLT

The **xslide** package for an Emacs major mode for editing XSL stylesheets.

`xsl-mode`, which **xslide** defines, is derived from `nxml-mode`.

Note that "xslide" is pronounced as one word, similar to "slide".  It
is not spelled out as "x-s-l-i-d-e".

## xslide versions

Current **xslide** version numbers start with '3' because **xslide** is based on `nxml-mode` using the [XSLT 3.0 schema](https://github.com/innovimax/xslt30) by Mohamed Zergaoui as [packaged](https://github.com/ndw/xslt-relax-ng) by Norman Tovey-Walsh.

**xslide** 2.m.n used the XSLT 2.0 version of the schema.

[xslide 0.2.2](https://sourceforge.net/projects/xslide/files/xslide/0.2.2/) is the last version available on [SourceForge](https://sourceforge.net/projects/xslide/). It used a built-in list of elements and attributes to validate the XSLT.

### Comparison with xslide 0.2.2

Some of the features of xslide 0.2.2 have been removed because it was not clear if anyone was using them, and because **xslide** no longer includes `xslide-data.el` now that **xslide** uses a RELAX NG schema for validation.

Please open an issue for an absent feature that you were using and still need.

## Installing

Unzip or untar the files from the current release, then add the directory containing the files to your `auto-mode-alist` and associate XSLT files with **xslide**.

### `.emacs` file

Add the contents of `dot_emacs` to your `.emacs` file:

```elisp
(setq load-path
      (append
       (list
	"/your/path/to/xslide" ; (expand-file-name "~/site-lisp/xslide")
	)
       load-path))

;; XSL stylesheet mode.
(autoload 'xsl-mode "xslide3" "Major mode for XSL stylesheets." t)
(setq auto-mode-alist
      (append
       (list
	'("\\.xslt?$" . xsl-mode))
       auto-mode-alist))
```
