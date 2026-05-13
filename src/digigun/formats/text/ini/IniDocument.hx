package digigun.formats.text.ini;

/**
 * Editable document model for an INI file.
 */
class IniDocument {
  /** Properties declared before any named section. */
  public final globalProperties:Array<IniProperty>;
  /** Named sections contained in the document. */
  public final sections:Array<IniSection>;

  /**
   * Creates a new INI document.
   */
  public function new(?globalProperties:Array<IniProperty>, ?sections:Array<IniSection>) {
    this.globalProperties = globalProperties == null ? [] : globalProperties.copy();
    this.sections = sections == null ? [] : sections.copy();
  }

  /**
   * Returns the first global property with the matching key, if present.
   */
  public function getGlobalProperty(key:String):Null<IniProperty> {
    for (property in globalProperties) {
      if (property.key == key) {
        return property;
      }
    }

    return null;
  }

  /**
   * Returns whether a global property with the given key exists.
   */
  public function hasGlobalProperty(key:String):Bool {
    return getGlobalProperty(key) != null;
  }

  /**
   * Sets a global property value in place, creating the property when missing.
   */
  public function setGlobalProperty(key:String, value:IniValue):IniProperty {
    var existing = getGlobalProperty(key);
    if (existing != null) {
      existing.value = value;
      return existing;
    }

    var property = new IniProperty(key, value);
    globalProperties.push(property);
    return property;
  }

  /**
   * Removes the first global property with the given key.
   */
  public function removeGlobalProperty(key:String):Bool {
    for (index in 0...globalProperties.length) {
      if (globalProperties[index].key == key) {
        globalProperties.splice(index, 1);
        return true;
      }
    }

    return false;
  }

  /**
   * Returns the first section with the matching name, if present.
   */
  public function getSection(name:String):Null<IniSection> {
    for (section in sections) {
      if (section.name == name) {
        return section;
      }
    }

    return null;
  }

  /**
   * Returns whether a section with the given name exists.
   */
  public function hasSection(name:String):Bool {
    return getSection(name) != null;
  }

  /**
   * Returns an existing section or creates one in place when it does not exist.
   */
  public function getOrCreateSection(name:String):IniSection {
    var existing = getSection(name);
    if (existing != null) {
      return existing;
    }

    var section = new IniSection(name);
    sections.push(section);
    return section;
  }

  /**
   * Removes the first section with the given name.
   */
  public function removeSection(name:String):Bool {
    for (index in 0...sections.length) {
      if (sections[index].name == name) {
        sections.splice(index, 1);
        return true;
      }
    }

    return false;
  }

  /**
   * Returns a copy of the document with one more global property.
   */
  public function withGlobalProperty(key:String, value:IniValue):IniDocument {
    var nextGlobalProperties = globalProperties.copy();
    nextGlobalProperties.push(new IniProperty(key, value));
    return new IniDocument(nextGlobalProperties, sections);
  }

  /**
   * Returns a copy of the document with an additional section.
   */
  public function withSection(section:IniSection):IniDocument {
    var nextSections = sections.copy();
    nextSections.push(section);
    return new IniDocument(globalProperties, nextSections);
  }
}
