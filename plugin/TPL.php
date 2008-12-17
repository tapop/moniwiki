<?php
// Copyright 2008 Won-Kyu Park <wkpark at kldp.org>
// All rights reserved. Distributable under GPL see COPYING
// a TPL plugin using the Templete_ processor
//
// Author: Won-Kyu Park <wkpark@kldp.org>
// Date: 2008-12-17
// Name: a TPL plugin
// Description: a TPL plugin wapper for the Templete_ processor
// URL: MoniWiki:TPLProcessor
// Version: $Revision$
// License: GPL
//
// Usage: [[TPL({=md5(time())})]]
//
// $Id$

function macro_TPL($formatter, $value, $params=array()) {
    return $formatter->processor_repl('tpl_', $value, $params);
}

// vim:et:sts=4:sw=4:
?>
