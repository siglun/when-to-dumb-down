.TL
Dumb-down at Indexing
.br  
Nested Data in the Solr Search Engine
.AU
\fISigfrid Lundberg\fP
.AI
Digital Transformation
Royal Danish Library
Post box 2149
1016 Copenhagen K
Denmark
.AB
.LP
This is a discussion of how to index and present metadata with possibly innumerable number of fields. We reject the idea to use the joins and hierarchically structured documents in a search engine like SOLR.
.LP
Instead we turn to the dumb down concept used by metadata communities to describe what goes on when crosswalking a complex metadata system with a more shallow, less detailed one.
.AE
.SH
Introduction
.LP
The Royal Danish Library has been using the
.pdfhref L -D solr Solr
\&search engine for at least a decade. Almost all projects that need some search facilities are using it. A Swiss army knife for searching in small as well as well as big data sets. A trusty tool that provide many advantages to the alternative to use a relational database management system (RDBMS) when working with resource discovery systems.
.LP
At the first Solr workshop I participated the teacher reiterated over and over again that Solr is a search engine, not a data management tool. Although Solr can Create, Retrieve, Update and Delete
.pdfhref L -D crud (CRUD)
\&documents, the transactions cannot really be characterized as having Atomicity, Consistency, Isolation and Durability
.pdfhref L -D acid (ACID)
\&
.SH
The role of bibliographic structure
.LP
In a library we encounter data with much more structure than simple packages of attributes and values, but also much less structure than what you expect from data in
.pdfhref L -D normal-form database normal form
\&. Bibliographical data may
\fBfor
        instance\fP
describe texts that
.IP \s+1\(bu\s-1
have one or more titles, each having different type (main title, subtitle, translated title, transcribed title, uniform title to iterate some of the frequently used ones)
.IP \s+1\(bu\s-1
may have one or more authors that may be persons or organizations
.IP \s+1\(bu\s-1
each of which may have dates of birth and death
.IP \s+1\(bu\s-1
and an affiliation
.LP
If we were using a RDBMS, the data on persons could be stored in one database table, the titles in another and there could be a third table keeping track (through joins and foreign keys) of each person's relations to the works to which they've contributed. Someone made the illustrations, someone else wrote the texts. A third one made the graphical design.
.LP
For a portrait photograph we have one person being the photographer, and another being the subject. The data on the subject can be as important as the data on the artist.
.LP
These data are important. For instance the dates are used for distinguishing between people with the same name. (The digital phone book krak.dk lists 43 now living persons named
\fISøren Kierkegaard\fP
, while
\fIthe philosopher\fP
died 1855). An importand use case is how to decide whether a given object is free from copyright or not, such as when the originator has been dead for more than 75 years.
.LP
Add to this that there are many more complications, like we may have multiple copies of a given title and that each copy may belong to different collections with very different provenance. For historical objects we may even have a manuscript in the manuscript and rare books collections and a modern pocket book in the open stocks.
.LP
The role of the primary purpose of these data are to enable library patrons and service users to search and retrieve. Typically users type a single word in the search form, while ignoring the handful of fields that we provide through the effort of catalogers, software developers etc.
.LP
The user gets a far too long list of results which contains author, title and perhaps some subjects or keywords. Again typically, the user clicks on a title an gets a landing page. This is far more detailed; it presents many fields that will enable users to decide whether to order or retrieve the object.
.LP
If we grossly simplify the process, a user might be up to one of two things: (1) Finding or resolving a given reference, i.e., the right object, perhaps the right edition. Or (2) Finding information on a given topic. See these two as endpoints on a scale.
.LP
You may look for a particular book \fIEnten — Eller (Either/Or)\fP by
\fIKierkegaard\fP
(1843) or you might be interested in the role of this philosopher in your study of the origin of existentialism. In the former case you actually look for Kierkegaard in the author field, in the latter case you look for him in subject field.
.KF
.PDFPIC sks-ee1-ill_k1.pdf 12.0c
.KE
.sp
.SH
Encoding, indexing and using
.LP
Assume we are about to add metadata on \fIEnten — eller\fP by
\fISøren Kierkegaard\fP
into a Solr index. What we get for that book might contain the data below. The example is encoded in a format called Metadata Object Description Schema (
.pdfhref L -D mods MODS
\&). Note that the namespace prefix `md` stands for the URI `http://www.loc.gov/mods/v3`
.DS L
\f(CR\s-2
        <md:titleInfo>
           <md:title>Enten - eller</md:title>
           <md:subTitle>Et livsfragment</md:subTitle>
        </md:titleInfo>
        <md:name displayLabel="Author"
                 type="personal"
                 authorityURI="https://viaf.org/viaf/7392250/"
                 xml:lang="en">
           <md:namePart type="family">Kierkegaard</md:namePart>
           <md:namePart type="given">Søren</md:namePart>
           <md:namePart type="date">1813/1855</md:namePart>
           <md:alternativeName altType="pseudonym">
              <md:namePart>Victor Eremita</md:namePart>
              <md:description>“Victorious hermit,” general editor of
              Either/Or, who also appears in the first part of its
              sequel, Stages on Life’s Way. Also the author of the
              satirical article “A Word of Thanks to Professor
              Heiberg.”</md:description>
           </md:alternativeName>
           <md:role>
              <md:roleTerm type="code">aut</md:roleTerm>
           </md:role>
        </md:name>
        
        <md:originInfo>
           <md:dateCreated>1843</md:dateCreated>
           <md:publisher>Universitetsboghandler C. A. Reitzel</md:publisher>
        </md:originInfo>
        \fP
.DE
.LP
This is a fake record I created for the purpose of this paper. The work has a
\fItitle\fP
and a
\fIname\fP
, which has a
\fIrole\fP
(which is
\fIaut\fP
as in author). The
\fIname\fP
also has multiple parts like family name (Kierkegaard), given name (Søren) and a date (1813/1855 which is ISO's way to express a
.pdfhref L -D dc-terms-date date
\&range i.e., the years between which the philosopher was alive. His
\fIFragment of Life\fP
.)
.LP
To get the birth and death dates you have to parse a string. As a matter of fact, the name on the book cover wasn't
\fISøren Kierkegaard\fP
but
\fIVictor Eremita\fP
(Victorious hermit), encoded as an <alternativeName>. A telling pseudonym of the author of The Seducer's Diary. Søren was good at
.pdfhref L -D pseudonyms pseudonyms
\&.
.LP
The <md:role> ... </md:role> permits the cataloger to encode that a person called
\fISøren\fP
has the
\f(CRaut\fP
relation to the work. Library of Congress have lists with houndreds of such
.pdfhref L -D relators relators
\&. Actually, each of those could be seen as a field. The thing is that even in a large bibliographic database there would be very few records where
\fIData manager\fP
(
\f(CRdtm\fP
),
\fIFormer owner\fP
(
\f(CRfmo\fP
) and
\fILibrettist\fP
(
\f(CRlbt\fP
) would contain any data.
.LP
Now we've identified a lot of possible fields to use, for cataloging and for information retrieval. They have perfectly reasonable use cases, and all of them are used in everyday library practice, so how do I get them into my Solr index?
.SH
The attempt
.LP
We have tried to put such records into Solr. The attempt was successful. In the rest of this paper I will outline how we did that, learn you a bit on how to use such an index and finally why decided not to implement it.
.LP
In our experiments we transformed MODS records to nested Solr records, such as the record below, which is transformed from my fake record above.
.DS L
\f(CR\s-2
[
  {
   "id": "https://example.org/record",
   "described": true,
   "entity_type": "the_object",
   "cataloging_language": "en",
   "record_created": "2022-08-12",
   "tit": [
        {
          "describing": "https://example.org/record",
          "described": false,
          "entity_type": "title main",
          "title": [
            "Enten - eller"
          ],
        "id": "https://example.org/record!disposable!subrecord!d1e21"
        }
   ],
   "aut": [
      {
          "id": "https://example.org/record!disposable!subrecord!d1e30",
          "authority": "https://viaf.org/viaf/7392250/",
          "described": false,
          "describing": "https://example.org/record",
          "language": "en",
          "entity_type": "aut",
          "agent_name": "Kierkegaard Søren (1813/1855)"
      }
   ],
   "visible_date": ["1843"],
  }
 ]
 
        \fP
.DE
.LP
If you are familiar with the workings of Solr, you know that the data-model (if I may label it as such) used is configured in a file call `schema.xml`. It basically contains list of fields that can be used in what is referred to as `Solr documents`. In such a schema you may add
.DS L
\f(CR\s-2
        <field     name="_nest_path_" 
                   type="_nest_path_" 
                   stored="true" 
                   indexed="true" />
        <field     name="_nest_parent_" 
                   type="string" 
                   indexed="true" 
                   stored="true" />
        \fP
.DE
.LP
the former of which is of the following type:
.DS L
\f(CR\s-2
        <fieldType name="_nest_path_" class="solr.NestPathField" />
        \fP
.DE
.LP
See the Solr  
.pdfhref W -D https://github.com/siglun/danish-sonnets/blob/main/nested-documents Indexing Nested Child Documents
documentation.
.LP
The nested indexing works since the indexer stores an xpath like entity for each record, making it possible track which Solr document which is parent and which document which is child which is the parent. That info is in the
\f(CR_nest_path_\fP
field and Solr does that automatically whenever it starts a new document inside a parent one.
.LP
You will get that information back from the server if you add a Solr field list argument (
\f(CRfl\fP
) at search time
.DS L
\f(CR\s-2
        fl=*,[child]
        \fP
.DE
.LP
That is straight forward. The problem is then to make Solr search in the child documents and return the parent or root document.
.DS L
\f(CR\s-2
{!parent which="described:true"}
         {!edismax v="agent_name:(Kierkegaard Søren) AND entity_type:aut"}
AND
{!parent which="described:true"}
         {!edismax v="title:(Enten - eller) AND entity_type:tit"}
        \fP
.DE
.LP
The constructs {!parent ... } and {!edismax ... } are so called local parameters in a Solr request. The former specifies that we want Solr to return parent documents such the described:true, the latter tells Solr we want the author to be Søren and title to be Enten — eller. Now we can reasonably easy search and retrieve information on the
\fIEtcher\fP
(
\f(CRetr\fP
) and
\fIDancer\fP
(
\f(CRdnc\fP
), when applicable.
.LP
This is a special case of
\f(CRjoin\fP
as implemented in Solr. Recall that joins are at very very core of
\f(CRSQL\fP
, and one of the features making the RDBMS such a powerful tool.
.LP
Also recall that I mentioned that my first Solr instructor dissuaded us from using search engines as data stores. Does that generalize to other features coming from the database world?
.SH
The user problems
.LP
I hope I've been able to convince you that the fairly complicated metadata structures used in libraries are useful for patrons and staff. They were not invented for giving software developers gray hair and age prematurely. Also, it is legitimate use case to be able to identify the etchers and the dancers.
.LP
However:
.IP 1
We do, however, know that users at of our resources are not very good at using fields. An interface allowing you to search portraiture subjects is very specialized use case. So is the use case to be able to search for senders and recipients of letters.
.IP 2
People do search for word in a title, but they do not search forA life fragmentseparate fromEither/or. Likewise they not particularly interested in making a difference betweenEnten — ellerandEither/or. If they search for the latter they presumably want an English translation, but when studying a detailed presentation they are almost certainly interested to know that Either/or is actually a translation.
.IP 3
You know, each performance ofВесна священная(AKA The Rite of Spring) has a conductor, director and choreographer and a lot of dancers, obviously in addition to
\fIСтравинский, Игорь Фёдорович\fP
(AKA
\fIStravinsky, Igor Fyodorovich\fP
the composer). I could go on here. You could add from your own experience.
.LP
To make a useful service we have to aggregate data into reasonable headlines. _[Dublin Core Metadata Initiative](https://www.dublincore.org/)_ has actually a name for this: The [Dumb-Down Principle](https://www.dublincore.org/resources/glossary/dumb-down_principle/)
.SH
The developer problems
.LP
From the developers point of view, metadata dumb-down can take place, either (i) when indexing or (ii) when searching.
.LP
In either case, for a ballet performance we would dumb-down _Composer_ ((
\f(CRcmp\fP
), Conductor ((
\f(CRcnd\fP
), Director ((
\f(CRdrt\fP
) and Choreographer ((
\f(CRchr\fP
) to one single repeatable field [creator](https://www.dublincore.org/specifications/dublin-core/dcmi-terms/terms/creator/). It would contain Igor Stravinsky (the transcribed, but perhaps also his name in Cyrillic), and obviously all other creatives. Most of the dancers would most likely go to the
.pdfhref L -D contributor contributor
\&field.
.LP
Doing dumb-down at indexing would mean to create fields
\f(CRcreator\fP
and
\f(CRcontributor\fP
in the index, to do it when searching would imply to do it using the horrendous search syntax presented above. Then you have to do the same for title and other relevant fields.
.LP
In the case of \fIEither/or\fP , \fIEnten — eller\fP the dumb-down solr record would look somewhat as the record below:
.DS L
\f(CR\s-2
        [
           {
           "id": "https:!!example.org!record",
           "title": [
              "Enten  &#8212; eller"
           ],
           "creator": [
              "Kierkegaard, Søren 1813/1855"
           ],
           "record_created": "2022-08-12",
           "visible_date": [
              "1843"
           ],
           "original_object_identifier": [],
           "pages": []
           }
        ]
        \fP
.DE
.LP
Hence when indexing we only create one record, and no joins are needed. A query could be
.DS L
\f(CR\s-2
        creator:kierkegaard AND title:(enten eller)
        \fP
.DE
.LP
The drawback being that the in the index we cannot tell the difference between
\fIIgor Stravinsky\fP
(
\f(CRcmp\fP
) and the
\fIConductor\fP
(
\f(CRcnd\fP
). Both are creators. The dumbed-down index has lost most of the information you need to decide whether you want to listen to an album or see a performance.
.IP \s+1\(bu\s-1
At indexing: Your search syntax is nice and clean. You have to use some other method to present the data in the detailed view.
.IP \s+1\(bu\s-1
At search: Your search syntax is very complicated. On the other hand, you have all the data needed for the detailed view.
.IP \s+1\(bu\s-1
At a practical level, the nested Solr seems more or less experimental, and the documentation is less than excellent. Only the  
.pdfhref W -D https://github.com/siglun/danish-sonnets/blob/main/lucene_query_parser lucene query parser
supports it, and when searching with (for example)
\f(CRedismax\fP
query parser you run into the syntactic problem with local parameters demonstrated above.
.LP
If we are to describe the situation in Model-View-Controller (MVC) terms, the second (i.e., the at search implementation) looks nice. One model, one controller but (perhaps) two views. When doing it at indexing, we need two models and an architecture diagram might look much more messy. Semantic exercise to make the dumb-down scheme might seem complicated. The code, however, is much simplified.
.LP
The fact that each substructure in the nested Solr document must follow the same schema is an annoying feature. It isn't important, but persons, subjects and whatever all have the same content model (in the sense of an XML DTD or Schema), makes the setup much less attractive.
.LP
Finally, it is my experience that it easier to accommodate multiple metadata models and standards in the same index with dumb-down at indexing. In our case we opted for transforming our MODS records to the
.pdfhref L -D schema.org schema.org
\&ontology for the detailed presentation. Hence, retrieval will be from a separate datastore. The schema.org ontology is rich enough for our landing pages and detailed result sets. It provides an extra bonus, we hope, in that Google would actually be able to index our collection.
.LP
The only advantage I can see with at search time dumb-down is that we would have only a single model in our search application.
.SH
Conclusion
.LP
In the end, after some weeks work, we threw out our nested indexing stuff and most likely we a threw out some baby we were not aware of with the bathwater. Be that as it may, we opted for an easy format for search, while retaining detail for presentation, and interoperability for other uses.
.LP
Library patrons have more needs than resource discovery. Some use APIs for study, research or for services of their own. The search index, schema.org, the original mods will eventually be available for such purposes. It could be that a nested index could actually be useful for such users.
.SH
References
.XP
.pdfhref M -N acid
ACID.  In:
\fIWikipedia\fP 
.br  
\s-2\f(CR
.pdfhref W -D https://en.wikipedia.org/wiki/ACID https://en.wikipedia.org/wiki/ACID
\fP\s+2
.XP
.pdfhref M -N pseudonyms
ConclusivePostscript,
2013. A “Who’s Who” of Kierkegaard’s Formidable Army of Pseudonyms. 
.br  
\s-2\f(CR
.pdfhref W -D https://www.reddit.com/r/philosophy/comments/1n2opm/a_whos_who_of_kierkegaards_formidable_army_of/ https://www.reddit.com/r/philosophy/comments/1n2opm/a_whos_who_of_kierkegaards_formidable_army_of/
\fP\s+2
.XP
.pdfhref M -N contributor
\fIContributor\fP 
.br  
\s-2\f(CR
.pdfhref W -D https://www.dublincore.org/specifications/dublin-core/dcmi-terms/terms/contributor/ https://www.dublincore.org/specifications/dublin-core/dcmi-terms/terms/contributor/
\fP\s+2
.XP
.pdfhref M -N crud
Create, read, update and delete.  In:
\fIWikipedia\fP 
.br  
\s-2\f(CR
.pdfhref W -D https://en.wikipedia.org/wiki/Create,_read,_update_and_delete https://en.wikipedia.org/wiki/Create,_read,_update_and_delete
\fP\s+2
.XP
.pdfhref M -N normal-form
Database normalization. 
.br  
\s-2\f(CR
.pdfhref W -D https://en.wikipedia.org/wiki/Database_normalization https://en.wikipedia.org/wiki/Database_normalization
\fP\s+2
.XP
.pdfhref M -N dc-terms-date
\fIDate\fP 
.br  
\s-2\f(CR
.pdfhref W -D https://www.dublincore.org/specifications/dublin-core/dcmi-terms/terms/date/ https://www.dublincore.org/specifications/dublin-core/dcmi-terms/terms/date/
\fP\s+2
.XP
.pdfhref M -N nested-documents
Indexing Nested Child Documents.  In:
\fIApache Solr Reference Guide\fP 
.br  
\s-2\f(CR
.pdfhref W -D https://solr.apache.org/guide/8_1/indexing-nested-documents.html https://solr.apache.org/guide/8_1/indexing-nested-documents.html
\fP\s+2
.XP
.pdfhref M -N mods
Library of Congress\fIMetadata Object Description Schema\fP 
.br  
\s-2\f(CR
.pdfhref W -D https://www.loc.gov/standards/mods/ https://www.loc.gov/standards/mods/
\fP\s+2
.XP
.pdfhref M -N relators
Library of Congress\fIMARC Code List for Relators\fP 
.br  
\s-2\f(CR
.pdfhref W -D https://www.loc.gov/marc/relators/relacode.html https://www.loc.gov/marc/relators/relacode.html
\fP\s+2
.XP
.pdfhref M -N solr
\fISolr\fP 
.br  
\s-2\f(CR
.pdfhref W -D https://solr.apache.org https://solr.apache.org
\fP\s+2
.XP
.pdfhref M -N lucene_query_parser
The Standard Query Parser.  In:
\fIApache Solr Reference Guide\fP 
.br  
\s-2\f(CR
.pdfhref W -D https://solr.apache.org/guide/6_6/the-standard-query-parser.html https://solr.apache.org/guide/6_6/the-standard-query-parser.html
\fP\s+2
.XP
.pdfhref M -N schema.org
\fIschema.org\fP 
.br  
\s-2\f(CR
.pdfhref W -D https://schema.org https://schema.org
\fP\s+2
