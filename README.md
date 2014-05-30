Debian-Backup-List-Applications (ListApp)
============

Description
------------
This tool is designed to backup (and restore) a list of applications installed on Debian.

For that, uses theses commands (thanks to http://goo.gl/eLbnwI).

To create a list of applications installed:

	dpkg --get-selections > program-list

To restore:

	sudo dpkg --set-selections > program-list
	sudo apt-get dselect-upgrade



Bug report
-------------
If you want to submit a bug ticket : [submit bug ticket](https://github.com/ygodard/Debian-Backup-List-Applications/issues).



Installation
---------
To install, after 'cd' to where you want to install:

	wget -O ListApp.sh --no-check-certificate https://raw.github.com/yvangodard/Debian-Backup-List-Applications/master/ListApp.sh; chmod 755 ListApp.sh



Help?
-------

    ./ListApp.sh -h



License
-------

Script by [Yvan GODARD](http://www.yvangodard.me) <godardyvan@gmail.com>.

This script is licensed under Creative Commons 4.0 BY NC SA.

<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0"><img alt="Licence Creative Commons" style="border-width:0" src="http://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png" /></a>


Limitations
-----------

THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS "AS IS" AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE REGENTS AND CONTRIBUTORS BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.