<?php
/**
	* @author Björn Schießle <schiessle@owncloud.com>
	* @author Jan-Christoph Borchardt, http://jancborchardt.net
	* @copyright Copyright (c) 2018, ownCloud GmbH
	* @license AGPL-3.0
	*
	* This code is free software: you can redistribute it and/or modify
	* it under the terms of the GNU Affero General Public License, version 3,
	* as published by the Free Software Foundation.
	*
	* This program is distributed in the hope that it will be useful,
	* but WITHOUT ANY WARRANTY; without even the implied warranty of
	* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
	* GNU Affero General Public License for more details.
	*
	* You should have received a copy of the GNU Affero General Public License, version 3,
	* along with this program.  If not, see <http://www.gnu.org/licenses/>
*/

class OC_Theme {

	/**
		* Returns the title
		* @return string title
	*/
	public function getTitle() {
		return 'ownCloud powered by Kopano';
	}

	/**
		* Returns mail header color
		* @return string
	*/
	public function getMailHeaderColor() {
		return '#0f70bd';
	}

}
