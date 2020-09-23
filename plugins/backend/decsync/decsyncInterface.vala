//	This file is part of FeedReader.
//
//	FeedReader is free software: you can redistribute it and/or modify
//	it under the terms of the GNU General Public License as published by
//	the Free Software Foundation, either version 3 of the License, or
//	(at your option) any later version.
//
//	FeedReader is distributed in the hope that it will be useful,
//	but WITHOUT ANY WARRANTY; without even the implied warranty of
//	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//	GNU General Public License for more details.
//
//	You should have received a copy of the GNU General Public License
//	along with FeedReader.  If not, see <http://www.gnu.org/licenses/>.

public class FeedReader.Extra : GLib.Object {
	public FeedReader.decsyncInterface plugin;

	public Extra(FeedReader.decsyncInterface plugin)
	{
		this.plugin = plugin;
	}
}

public class FeedReader.decsyncInterface : FeedServerInterface {

	internal DecsyncUtils m_utils;
	private Soup.Session m_session;
	internal Decsync.Decsync<Extra> m_sync;
	private string m_loginDir;
	private Gtk.Button loginButton;
	private Gtk.Spinner waitingSpinner;
	private Gtk.Stack loginStack;

	public override void init(GLib.SettingsBackend? settings_backend, Secret.Collection secrets)
	{
		m_utils = new DecsyncUtils(settings_backend);
		m_session = new Soup.Session();
		m_session.user_agent = Constants.USER_AGENT;
		m_session.timeout = 5;
	}

	public override string getWebsite()
	{
		return "https://github.com/39aldo39/DecSync";
	}

	public override BackendFlags getFlags()
	{
		return (BackendFlags.LOCAL | BackendFlags.FREE_SOFTWARE | BackendFlags.FREE);
	}

	public override string getID()
	{
		return "decsync";
	}

	public override string iconName()
	{
		return "feed-service-decsync";
	}

	public override string serviceName()
	{
		return "DecSync";
	}

	public override bool needWebLogin()
	{
		return false;
	}

	public override Gtk.Box? getWidget()
	{
		var doneLabel = new Gtk.Label(_("Done"));
		var waitingLabel = new Gtk.Label(_("Adding Feeds"));
		waitingSpinner = new Gtk.Spinner();
		var waitingBox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 5);
		waitingBox.pack_start(waitingSpinner, false, false, 0);
		waitingBox.pack_start(waitingLabel, true, false, 0);
		loginStack = new Gtk.Stack();
		loginStack.add_named(doneLabel, "label");
		loginStack.add_named(waitingBox, "waiting");
		var dirLabel = new Gtk.Label(_("DecSync directory:"));
		dirLabel.set_alignment(1.0f, 0.5f);
		dirLabel.set_hexpand(true);
		m_loginDir = m_utils.getDecsyncDir();
		var buttonLabel = m_loginDir;
		if (buttonLabel == "")
		{
			buttonLabel = _("Select...");
		}
		var dirButton = new Gtk.Button.with_label(buttonLabel);
		dirButton.clicked.connect(() => {
			var chooser = new Gtk.FileChooserDialog("Select Directory",
				null,
				Gtk.FileChooserAction.SELECT_FOLDER,
				_("_Cancel"),
				Gtk.ResponseType.CANCEL,
				_("_Select"),
			Gtk.ResponseType.ACCEPT);
			chooser.set_show_hidden(true);
			chooser.set_current_folder(m_loginDir);
			if (chooser.run() == Gtk.ResponseType.ACCEPT)
			{
				m_loginDir = chooser.get_filename();
				dirButton.set_label(m_loginDir);
			}
			chooser.close();
		});

		var grid = new Gtk.Grid();
		grid.set_column_spacing(10);
		grid.set_row_spacing(10);
		grid.set_valign(Gtk.Align.CENTER);
		grid.set_halign(Gtk.Align.CENTER);

		grid.attach(dirLabel, 0, 0, 1, 1);
		grid.attach(dirButton, 1, 0, 1, 1);

		//---------------------------------------------------------------------

		var logo = new Gtk.Image.from_icon_name("feed-service-decsync", Gtk.IconSize.MENU);

		var loginLabel = new Gtk.Label(_("Please select your DecSync directory and enjoy using FeedReader"));
		loginLabel.get_style_context().add_class("h2");
		loginLabel.set_justify(Gtk.Justification.CENTER);
		loginLabel.set_lines(3);

		loginButton = new Gtk.Button();
		loginButton.add(loginStack);
		loginButton.halign = Gtk.Align.END;
		loginButton.set_size_request(80, 30);
		loginButton.get_style_context().add_class(Gtk.STYLE_CLASS_SUGGESTED_ACTION);
		loginButton.clicked.connect(() => { tryLogin(); });

		var box = new Gtk.Box(Gtk.Orientation.VERTICAL, 10);
		box.valign = Gtk.Align.CENTER;
		box.halign = Gtk.Align.CENTER;
		box.pack_start(loginLabel, false, false, 10);
		box.pack_start(logo, false, false, 10);
		box.pack_start(grid, true, true, 10);
		box.pack_end(loginButton, false, false, 20);

		return box;
	}

	public override void writeData()
	{
		m_utils.setDecsyncDir(m_loginDir);
	}

	public override async void postLoginAction()
	{
		loginButton.set_sensitive(false);
		waitingSpinner.start();
		loginButton.get_style_context().remove_class(Gtk.STYLE_CLASS_SUGGESTED_ACTION);
		loginStack.set_visible_child_name("waiting");
		SourceFunc callback = postLoginAction.callback;
		new Thread<void*>(null, () => {
			var extra = new Extra(this);
			m_sync.init_stored_entries();
			m_sync.execute_all_stored_entries_for_path_exact({"feeds", "subscriptions"}, extra);
			Idle.add((owned) callback);
			return null;
		});
		yield;
	}

	public override bool supportTags()
	{
		return false;
	}

	public override bool doInitSync()
	{
		return false;
	}

	public override string symbolicIcon()
	{
		return "feed-service-decsync-symbolic";
	}

	public override string accountName()
	{
		return "DecSync";
	}

	public override string getServerURL()
	{
		return "http://localhost/";
	}

	public override string uncategorizedID()
	{
		return "0";
	}

	public override bool hideCategoryWhenEmpty(string catID)
	{
		return false;
	}

	public override bool supportCategories()
	{
		return true;
	}

	public override bool supportFeedManipulation()
	{
		return true;
	}

	public override bool supportMultiLevelCategories()
	{
		return true;
	}

	public override bool supportMultiCategoriesPerFeed()
	{
		return false;
	}

	public override bool syncFeedsAndCategories()
	{
		return false;
	}

	public override bool tagIDaffectedByNameChange()
	{
		return false;
	}

	public override void resetAccount()
	{
		return;
	}

	public override bool useMaxArticles()
	{
		return true;
	}

	public override LoginResponse login()
	{
		var decsyncDir = m_utils.getDecsyncDir();
		char ownAppId[256];
		Decsync.get_app_id("FeedReader", ownAppId);
		var error = Decsync.Decsync<Extra>.new(out m_sync, decsyncDir, "rss", null, (string)ownAppId);
		if (error != 0)
		{
			switch (error)
			{
				case 1:
					Logger.error("DecSync: Invalid .decsync-info");
					break;
				case 2:
					Logger.error("DecSync: Unsupported DecSync version");
					break;
				default:
					Logger.error("DecSync: Unknown error");
					break;
			}
			return LoginResponse.API_ERROR;
		}
		m_sync.add_listener({"articles","read"}, DecsyncListeners.readListener);
		m_sync.add_listener({"articles","marked"}, DecsyncListeners.markListener);
		m_sync.add_listener({"feeds","subscriptions"}, DecsyncListeners.subscriptionListener);
		m_sync.add_listener({"feeds","names"}, DecsyncListeners.feedNamesListener);
		m_sync.add_listener({"feeds","categories"}, DecsyncListeners.categoriesListener);
		m_sync.add_listener({"categories","names"}, DecsyncListeners.categoryNamesListener);
		m_sync.add_listener({"categories","parents"}, DecsyncListeners.categoryParentsListener);
		m_sync.init_done();
		return LoginResponse.SUCCESS;
	}

	public override bool serverAvailable()
	{
		return Utils.ping("https://duckduckgo.com/");
	}

	public override void setArticleIsRead(string articleIDs, ArticleStatus readStatus)
	{
		var read = readStatus == ArticleStatus.READ;
		Logger.debug("Mark " + articleIDs + " as " + (read ? "read" : "unread"));
		Decsync.EntryWithPath[] entries = {};
		var db = DataBase.readOnly();
		foreach (var articleID in articleIDs.split(","))
		{
			Article? article = db.read_article(articleID);
			if (article != null)
			{
				var path = articleToPath(article, "read");
				var key = stringToJson(article.getArticleID());
				var value = boolToJson(read);
				entries += new Decsync.EntryWithPath(path, key, value);
			}
		}
		m_sync.set_entries(entries);
	}

	public override void setArticleIsMarked(string articleID, ArticleStatus markedStatus)
	{
		var marked = markedStatus == ArticleStatus.MARKED;
		Logger.debug("Mark " + articleID + " as " + (marked ? "marked" : "unmarked"));
		Article? article = DataBase.readOnly().read_article(articleID);
		if (article != null)
		{
			var path = articleToPath(article, "marked");
			var key = stringToJson(article.getArticleID());
			var value = boolToJson(marked);
			m_sync.set_entry(path, key, value);
		}
	}

	public override bool alwaysSetReadByID()
	{
		return true;
	}

	public override void setFeedRead(string feedID)
	{
		return;
	}

	public override void setCategoryRead(string catID)
	{
		return;
	}

	public override void markAllItemsRead()
	{
		return;
	}

	public override void tagArticle(string articleID, string tagID)
	{
		return;
	}

	public override void removeArticleTag(string articleID, string tagID)
	{
		return;
	}

	public override string createTag(string caption)
	{
		return "";
	}

	public override void deleteTag(string tagID)
	{
		return;
	}

	public override void renameTag(string tagID, string title)
	{
		return;
	}

	public override bool addFeed(string feedURL, string? catID, string? newCatName, out string feedID, out string errmsg)
	{
		return addFeedWithDecsync(feedURL, catID, newCatName, out feedID, out errmsg);
	}

	public bool addFeedWithDecsync(string feedURL, string? catID, string? newCatName, out string feedID, out string errmsg, bool updateDecsync = true)
	{
		var db = DataBase.writeAccess();
		var catIDs = new Gee.ArrayList<string>();
		if(catID == null && newCatName != null)
		{
			string cID = createCategory(newCatName, null);
			var cat = new Category(cID, newCatName, 0, 99, CategoryID.MASTER.to_string(), 1);
			db.write_categories(ListUtils.single(cat));
			catIDs.add(cID);
		}
		else if(catID != null && newCatName == null)
		{
			catIDs.add(catID);
		}
		else
		{
			catIDs.add(uncategorizedID());
		}

		feedID = feedURL;

		Logger.info(@"addFeed: ID = $feedID");
		Feed? feed = m_utils.downloadFeed(m_session, feedURL, feedID, catIDs, out errmsg);

		if(feed != null)
		{
			if(!db.feed_exists(feed.getXmlUrl()))
			{
				db.write_feeds(ListUtils.single(feed));

				if (updateDecsync)
				{
					m_sync.set_entry({"feeds", "subscriptions"}, stringToJson(feedID), boolToJson(true));
					renameFeed(feedID, feed.getTitle());
					moveFeed(feedID, feed.getCatString(), null);
				}

				var extra = new Extra(this);
				m_sync.execute_stored_entry({"feeds", "names"}, stringToJson(feedID), extra);
				m_sync.execute_stored_entry({"feeds", "categories"}, stringToJson(feedID), extra);

				return true;
			}
			errmsg = _("Can't add feed because it already exists: ") + feedURL;
		}

		return false;
	}

	public override void removeFeed(string feedID)
	{
		m_sync.set_entry({"feeds", "subscriptions"}, stringToJson(feedID), boolToJson(false));
	}

	public override void renameFeed(string feedID, string title)
	{
		m_sync.set_entry({"feeds", "names"}, stringToJson(feedID), stringToJson(title));
	}

	public override void moveFeed(string feedID, string newCatID, string? currentCatID)
	{
		string? value = newCatID == uncategorizedID() ? null : newCatID;
		m_sync.set_entry({"feeds", "categories"}, stringToJson(feedID), stringToJson(value));
	}

	public override string createCategory(string title, string? parentID)
	{
		var db = DataBase.readOnly();
		string? catID = db.getCategoryID(title);
		while (catID == null || db.read_category(catID) != null)
		{
			catID = "catID%05d".printf(Random.int_range(0, 100000));
		}
		renameCategory(catID, title);
		moveCategory(catID, parentID ?? CategoryID.MASTER.to_string());
		Logger.info("createCategory: ID = " + catID);
		return catID;
	}

	public override void renameCategory(string catID, string title)
	{
		m_sync.set_entry({"categories", "names"}, stringToJson(catID), stringToJson(title));
	}

	public override void moveCategory(string catID, string newParentID)
	{
		string? value = newParentID == CategoryID.MASTER.to_string() ? null : newParentID;
		m_sync.set_entry({"categories", "parents"}, stringToJson(catID), stringToJson(value));
	}

	public override void deleteCategory(string catID)
	{
		Logger.info("Delete category " + catID);
		var feedIDs = DataBase.readOnly().getFeedIDofCategorie(catID);
		foreach (var feedID in feedIDs)
		{
			moveFeed(feedID, uncategorizedID(), catID);
		}
	}

	public override void removeCatFromFeed(string feedID, string catID)
	{
		moveFeed(feedID, uncategorizedID(), catID);
	}

	public override bool getFeedsAndCats(Gee.List<Feed> feeds, Gee.List<Category> categories, Gee.List<Tag> tags, GLib.Cancellable? cancellable = null)
	{
		return true;
	}

	public override int getUnreadCount()
	{
		return 0;
	}

	public override void getArticles(int count, ArticleStatus whatToGet, DateTime? since, string? feedID, bool isTagID, GLib.Cancellable? cancellable = null)
	{
		var extra = new Extra(this);
		m_sync.execute_all_new_entries(extra);

		var feeds = DataBase.readOnly().read_feeds();
		var articles = new Gee.ArrayList<Article>();
		GLib.Mutex mutex = GLib.Mutex();
		DateTime? dropDate = ((DropArticles)Settings.general().get_enum("drop-articles-after")).to_start_date();

		try
		{
			var threads = new ThreadPool<Feed>.with_owned_data((feed) => {
				if(cancellable != null && cancellable.is_cancelled())
				{
					return;
				}

				Logger.debug("getArticles for feed: " + feed.getTitle());
				string url = feed.getXmlUrl().escape("");

				if(url == null || url == "" || GLib.Uri.parse_scheme(url) == null)
				{
					Logger.error("no valid URL");
					return;
				}

				var msg = new Soup.Message("GET", url);
				var session = new Soup.Session();
				session.user_agent = Constants.USER_AGENT;
				session.timeout = 5;
				session.send_message(msg);
				string xml = (string)msg.response_body.flatten().data;

				// parse
				Rss.Parser parser = new Rss.Parser();
				try
				{
					parser.load_from_data(xml, xml.length);
				}
				catch(GLib.Error e)
				{
					Logger.error("decsyncInterface.getArticles: %s".printf(e.message));
					return;
				}
				var doc = parser.get_document();

				string? locale = null;
				if(doc.encoding != null
				&& doc.encoding != "")
				{
					locale = doc.encoding;
				}

				Logger.debug("Got %u articles".printf(doc.get_items().length()));
				var newArticles = new Gee.ArrayList<Article>();
				var db = DataBase.readOnly();
				foreach(Rss.Item item in doc.get_items())
				{
					string? articleID = item.guid;

					if(articleID == null)
					{
						if(item.link == null)
						{
							Logger.warning("no valid id and no valid URL as well? what the hell man? I'm giving up");
							continue;
						}

						articleID = item.link;
					}

					if (db.read_article(articleID) != null)
					{
						continue;
					}

					var date = Rfc822.parseDate(item.pub_date);
					if (date != null)
					{
						Logger.info(@"Parsed $(item.pub_date) as $(date.to_string())");
					}
					else
					{
						if (item.pub_date != null)
						{
							Logger.warning(@"RFC 822 date parser failed to parse $(item.pub_date). Falling back to DateTime.now()");
						}
						date = new DateTime.now_local();
					}

					if (dropDate != null && date.compare(dropDate) == -1)
					{
						continue;
					}

					//Logger.info("Got content: " + item.description);
					string? content = m_utils.convert(item.description, locale);
					//Logger.info("Converted to: " + item.description);
					if(content == null)
					{
						content = _("Nothing to read here.");
					}

					var enclosures = new Gee.ArrayList<Enclosure>();

					if(item.enclosure_url != null)
					{
						// FIXME: check what type of media we actually got
						enclosures.add(new Enclosure(articleID, item.enclosure_url, EnclosureType.FILE));
					}

					string articleURL = item.link;
					if(articleURL.has_prefix("/"))
					{
						articleURL = feed.getURL() + articleURL.substring(1);
					}

					var article = new Article(
						articleID,
						(item.title != null) ? m_utils.convert(item.title, locale) : null,
						articleURL,
						feed.getFeedID(),
						ArticleStatus.UNREAD,
						ArticleStatus.UNMARKED,
						content,
						content,
						m_utils.convert(item.author, locale),
						date,
						0,
						null,
						enclosures
					);

					Logger.debug("Got new article: " + article.getTitle());

					newArticles.add(article);
				}
				mutex.lock();
				articles.add_all(newArticles);
				mutex.unlock();
			}, (int)GLib.get_num_processors(), true);

			foreach(Feed feed in feeds)
			{
				try
				{
					threads.add(feed);
				}
				catch(GLib.Error e)
				{
					Logger.error("Error creating thread to download Feed %s: %s".printf(feed.getTitle(), e.message));
				}
			}

			bool immediate = false;         // allow to queue up additional tasks
			bool wait = true;         // function will block until all tasks are done
			ThreadPool.free((owned)threads, immediate, wait);
		}
		catch(Error e)
		{
			Logger.error("Error creating threads to download Feeds: " + e.message);
		}

		articles.sort((a, b) => {
			return strcmp(a.getArticleID(), b.getArticleID());
		});

		if(articles.size > 0)
		{
			DataBase.writeAccess().write_articles(articles);
			Logger.debug("decsyncInterface: %i articles written".printf(articles.size));

			Decsync.StoredEntry[] storedEntries = {};
			foreach (var article in articles) {
				var pathRead = articleToPath(article, "read");
				var pathMarked = articleToPath(article, "marked");
				var key = stringToJson(article.getArticleID());
				storedEntries += new Decsync.StoredEntry(pathRead, key);
				storedEntries += new Decsync.StoredEntry(pathMarked, key);
			}
			m_sync.execute_stored_entries(storedEntries, extra);
		}

		FeedReaderBackend.get_default().updateBadge();
		refreshFeedListCounter();
		newFeedList();
		updateArticleList();
	}

	private string[] articleToPath(Article article, string type)
	{
		var path = new Gee.ArrayList<string>();
		path.add("articles");
		path.add(type);
		var datetime = article.getDate().to_utc();
		path.add(datetime.format("%Y"));
		path.add(datetime.format("%m"));
		path.add(datetime.format("%d"));
		return path.to_array();
	}

	private string boolToJson(bool input)
	{
		var node = new Json.Node(Json.NodeType.VALUE);
		node.set_boolean(input);
		return Json.to_string(node, false);
	}

	private string stringToJson(string? input)
	{
		Json.Node node;
		if (input == null) {
			node = new Json.Node(Json.NodeType.NULL);
		} else {
			node = new Json.Node(Json.NodeType.VALUE);
			node.set_string(input);
		}
		return Json.to_string(node, false);
	}
}

[ModuleInit]
public void peas_register_types(GLib.TypeModule module)
{
	var objmodule = module as Peas.ObjectModule;
	objmodule.register_extension_type(typeof(FeedReader.FeedServerInterface), typeof(FeedReader.decsyncInterface));
}
