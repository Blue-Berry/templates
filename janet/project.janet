(declare-project
  :name "hello"
  :main "main"
  :dependencies ["spork"])

(declare-executable
  :name "hello"
  :entry "main.janet"
  :install true)
