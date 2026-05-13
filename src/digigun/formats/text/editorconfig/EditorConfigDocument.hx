package digigun.formats.text.editorconfig;

import digigun.formats.text.ini.IniDocument;
import digigun.formats.text.ini.IniProperty;
import digigun.formats.text.ini.IniSection;

/**
 * Editable document model for the supported EditorConfig subset.
 *
 * The underlying storage reuses the existing INI document model.
 */
class EditorConfigDocument {
  /** Backing INI document. */
  public final ini:IniDocument;

  /**
   * Creates a new EditorConfig document.
   */
  public function new(?ini:IniDocument) {
    this.ini = ini == null ? new IniDocument() : ini;
  }

  /**
   * Returns the backing global properties.
   */
  public var globalProperties(get, never):Array<IniProperty>;

  /**
   * Returns the backing sections.
   */
  public var sections(get, never):Array<IniSection>;

  public inline function get_globalProperties():Array<IniProperty> {
    return ini.globalProperties;
  }

  public inline function get_sections():Array<IniSection> {
    return ini.sections;
  }

  /**
   * Returns whether the special `root` preamble property is set to `true`.
   */
  public function getRoot():Bool {
    var property = ini.getGlobalProperty("root");
    return property != null && property.value.asString().toLowerCase() == "true";
  }

  /**
   * Sets the special `root` preamble property.
   */
  public function setRoot(value:Bool):IniProperty {
    return ini.setGlobalProperty("root", value ? "true" : "false");
  }

  /**
   * Removes the special `root` preamble property.
   */
  public function removeRoot():Bool {
    return ini.removeGlobalProperty("root");
  }

  /**
   * Returns the first global property with the given key.
   */
  public inline function getGlobalProperty(key:String):Null<IniProperty> {
    return ini.getGlobalProperty(key.toLowerCase());
  }

  /**
   * Sets a global property.
   */
  public inline function setGlobalProperty(key:String, value:String):IniProperty {
    return ini.setGlobalProperty(key.toLowerCase(), value);
  }

  /**
   * Removes the first global property with the given key.
   */
  public inline function removeGlobalProperty(key:String):Bool {
    return ini.removeGlobalProperty(key.toLowerCase());
  }

  /**
   * Returns the first section with the matching glob, if present.
   */
  public inline function getSection(glob:String):Null<IniSection> {
    return ini.getSection(glob);
  }

  /**
   * Returns whether a section with the given glob exists.
   */
  public inline function hasSection(glob:String):Bool {
    return ini.hasSection(glob);
  }

  /**
   * Returns an existing section or creates one when it does not exist.
   */
  public inline function getOrCreateSection(glob:String):IniSection {
    return ini.getOrCreateSection(glob);
  }

  /**
   * Removes the first section with the given glob.
   */
  public inline function removeSection(glob:String):Bool {
    return ini.removeSection(glob);
  }
}
