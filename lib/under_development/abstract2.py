# -*- coding: utf-8 -*-
from abc import ABCMeta, abstractmethod
import MeCab
from time import sleep
import nltk
import numpy
import re
import sys
import os
import glob
from PyPDF2 import PdfFileWriter, PdfFileReader
import pandas as pd


TOKEN = '''<div\s.+?><span\s.+?>[1-9][. ].*</span><span\s.+?>.+?\n<br></span></div>'''
FOOTER = '''<div\s.+>(<span\s.+>[1-9]\s</span><span\s.+>(.|\n)+</span>)+</div>'''
THESIS_DIR = '''../thesis_data/ignore/'''
STUDENT_DATA = '''\s*(.+?)(?:\n|\s)?[(（]?(\d{8})[)）]?'''


class AbstractableDoc(metaclass=ABCMeta):
    '''
    文書の自動要約アルゴリズム。

    文書要約で不要となるトークンのフィルタリングのアルゴリズムが複数個想定されるため、
    GoFに由来する委譲型のStrategy Patternで実装しておく。

    そのためこの抽象クラスは「事実上の」インターフェイスとして再利用させる。

    以下の文献に準拠する。
    Luhn, Hans Peter. "The automatic creation of literature abstracts."
    IBM Journal of research and development 2.2 (1958): 159-165.

    Matthew A. Russell　著、佐藤 敏紀、瀬戸口 光宏、原川 浩一　監訳、長尾 高弘　訳
    『入門 ソーシャルデータ 第2版――ソーシャルウェブのデータマイニング』 2014年06月 発行
    URL：http://www.oreilly.co.jp/books/9784873116792/

    ただしオライリー本はpython2で英語の文書を対象としていて、
    尚且つ掲載されているサンプルコードもリファクタリングの余地のある内容であったため、
    再設計する。
    '''

    @abstractmethod
    def filter(self, scored_list):
        '''
        フィルタリングを実行する。

        標準偏差やTOP N Rankなど、フィルタリングの具体的な実装は下位クラスに任せる。

        Args:
            scored_list:    文章ごとの重要度を近接した文で頻出する度合いで点数化・スコアリングした内容。

        Retruns:
            引数として入力したリスト型のデータを対象に、
            フィルタリングした結果をリスト型で返す。

        '''
        raise NotImplementedError("This method must be implemented.")


class AbstractableStd(AbstractableDoc):
    '''
    標準偏差との差異の度合いから、
    文書要約で不要となるトークンを除去する。
    平均スコアにフィルタとしての標準偏差の半分を加算した値を利用して、
    重要ではないと見做したトークンを除去していく。
    '''

    def filter(self, scored_list):
        '''
        標準偏差を用いてフィルタリングを実行する。

        Args:
            scored_list:    文章ごとの重要度を近接した文で頻出する度合いで点数化・スコアリングした内容。

        Retruns:
            引数として入力したリスト型のデータを対象に、
            フィルタリングした結果をリスト型で返す。

        '''
        if len(scored_list) > 0:
            avg = numpy.mean([s[1] for s in scored_list])
            std = numpy.std([s[1] for s in scored_list])
        else:
            avg = 0
            std = 0
        limiter = avg + 0.5 * std
        mean_scored = [(sent_idx, score) for (sent_idx, score) in scored_list if score > limiter]
        return mean_scored


class AbstractableTopNRank(AbstractableDoc):
    '''
    トップNにランク付けされたトークンだけを返す。
    '''

    # トップNのNの値
    __top_n = 10

    def get_top_n(self):
        '''
        getter
        委譲先でメソッドが実行された際に参照される。

        Returns:
            トップNのNの値を数値型で返す。

        '''
        if isinstance(self.__top_n, int) is False:
            raise TypeError("The type of __top_n must be int.")
        return self.__top_n

    def set_top_n(self, value):
        '''
        setter
        デフォルトから変えたいなら委譲前に。

        Args:
            value:  トップNのNの値。

        Raises:
            TypeError: 引数に数値以外の方の変数を入力した場合に発生する。

        '''
        if isinstance(value, int) is False:
            raise TypeError("The type of __top_n must be int.")
        self.__top_n = value

    # トップNのNのプロパティ
    top_n = property(get_top_n, set_top_n)

    def filter(self, scored_list):
        '''
        TOP N Rankでフィルタリングを実行する。

        Args:
            scored_list:    文章ごとの重要度を近接した文で頻出する度合いで点数化・スコアリングした内容。

        Retruns:
            引数として入力したリスト型のデータを対象に、
            フィルタリングした結果をリスト型で返す。

        '''
        top_n_key = -1 * self.top_n
        top_n_list = sorted(scored_list, key=lambda x: x[1])[top_n_key:]
        result_list = sorted(top_n_list, key=lambda x: x[0])
        return result_list


class TextMining(metaclass=ABCMeta):
    '''
    自然言語処理系の抽象基底クラス。
    別の用途で制作したクラスを再利用している。

    今回のデモ用に暫定的にコーディングした。
    nltkとMeCabをつなぎこめるようなクラス構成にしても良いかもしれない。
    '''

    # トークンのリスト
    __token = []

    def set_token(self, value):
        '''
        setter
        トークンのリスト。

        Args:
            value: トークンのリスト

        '''
        self.__token = value

    def get_token(self):
        '''
        getter

        Returns:
            トークンのリストを返す。

        '''
        return self.__token

    # トークンのリストのプロパティ
    token = property(get_token, set_token)

    def tokenize(self, data):
        '''
        形態素解析して、トークンをプロパティ：tokenにセットする。

        Args:
            形態素解析対象となる文字列。

        '''
        mt = MeCab.Tagger("-d /usr/local/lib/mecab/dic/mecab-ipadic-neologd -Owakati")
        wordlist = mt.parse(data)
        self.token = wordlist.rstrip(" \n").split(" ")

    def listup_sentence(self, data, counter=0):
        '''
        日本語を文ごとに区切る。
        暫定的に、ここでは「．」で区切る。

        Args:
            data:       区切る対象となる文字列。
            counter:    再帰回数。

        Returns:
            文ごとに区切った結果として、一文ずつ格納したリスト。

        '''
        seq_list = ["．"]
        seq = seq_list[counter]
        sentence_list = []
        [sentence_list.append(sentence + seq) for sentence in data.split(seq) if sentence != ""]
        if counter + 1 < len(seq_list):
            sentence_list_r = []
            for sentence in sentence_list:
                sentence_list_r.extend(self.listup_sentence(sentence, counter+1))

            sentence_list = sentence_list_r

        return sentence_list


class AutoAbstractor(TextMining):
    '''
    文書の自動要約アルゴリズム。
    文書要約で不要となるトークンのフィルタリングのアルゴリズムが複数個想定されるため、
    GoFに由来する委譲型のStrategy Patternで実装しておく。

    '''

    # 考慮するトークンの数
    __target_n = 100

    def get_target_n(self):
        '''
        getter

        Returns:
            考慮するトークンの数の数値。

        Raises:
            TypeError: プロパティにセットされているのが数値以外の型である場合に発生する。

        '''
        if isinstance(self.__target_n, int) is False:
            raise TypeError("The type of __target_n must be int.")
        return self.__target_n

    def set_target_n(self, value):
        '''
        setter

        Args:
            value:      考慮するトークンの数の数値。

        Raise:
            TypeError:  引数が数値以外の型である場合に発生する。

        '''
        if isinstance(value, int) is False:
            raise TypeError("The type of __target_n must be int.")
        self.__target_n = value

    # 考慮するトークンの数のプロパティ
    target_n = property(get_target_n, set_target_n)

    # 考慮するトークン間の距離
    __cluster_threshold = 5

    def get_cluster_threshold(self):
        '''
        getter

        Return:
            考慮するトークンの数の数の距離の数値型。

        Raises:
            プロパティにセットされているのが数値以外の型である場合に発生する。

        '''
        if isinstance(self.__cluster_threshold, int) is False:
            raise TypeError("The type of __cluster_threshold must be int.")
        return self.__cluster_threshold

    def set_cluster_threshold(self, value):
        '''
        setter

        Args:
            value:      考慮するトークンの数

        Raises:
            引数が数値以外の型である場合に発生する。

        '''
        if isinstance(value, int) is False:
            raise TypeError("The type of __cluster_threshold must be int.")
        self.__cluster_threshold = value

    # 考慮するトークンの数のプロパティ
    cluster_threshold = property(get_cluster_threshold, set_cluster_threshold)

    # トップNの要約結果として返す数
    __top_sentences = 5

    def get_top_sentences(self):
        '''
        getter

        Returns:
            トップNの要約結果として返す数。

        Raises:
            TypeError:  プロパティにセットされているのが数値以外の型である場合に発生する。

        '''
        if isinstance(self.__top_sentences, int) is False:
            raise TypeError("The type of __top_sentences must be int.")
        return self.__top_sentences

    def set_top_sentences(self, value):
        '''
        setter

        Args:
            value:      トップNの要約結果として返す数。

        Raises:
            TypeError:  引数の型が数値以外の型である場合に発生する。

        '''
        if isinstance(value, int) is False:
            raise TypeError("The type of __top_sentences must be int.")
        self.__top_sentences = value

    # トップNの要約結果として返す数のプロパティ
    top_sentences = property(get_top_sentences, set_top_sentences)

    def summarize(self, document, Abstractor):
        '''
        文書要約を実行する。

        Args:
            document:       要約対象となる文書の文字列。
            Abstractor:     インターフェイス：AbstractableDocを実現したオブジェクト。

        Returns:
            以下の形式の辞書。

            {
                "summarize_result": "{要約結果を一文一要素として格納したリスト｝",
                "scoring_data":     "{summarize_resultの各要素に紐付くスコアリング結果｝"
            }

        Raises:
            TypeError:      引数：documentが文字列ではない場合に発生する。
            TypeError:      引数：Abstractorの型がAbstractableDocではない場合に発生する。

        '''
        if isinstance(document, str) is False:
            raise TypeError("The type of document must be str.")

        if isinstance(Abstractor, AbstractableDoc) is False:
            raise TypeError("The type of Abstractor must be AbstractableDoc.")

        self.tokenize(document)

        words = self.token
        normalized_sentences = self.listup_sentence(document)

        fdist = nltk.FreqDist(words)

        top_n_words = [w[0] for w in fdist.items()][:self.target_n]

        scored_list = self.__closely_associated_score(normalized_sentences, top_n_words)

        filtered_list = Abstractor.filter(scored_list)

        result_list = [normalized_sentences[idx] for (idx, score) in filtered_list]

        result_dict = {
            "summarize_result": result_list,
            "scoring_data": filtered_list
        }

        return result_dict

    def __closely_associated_score(self, normalized_sentences, top_n_words):
        '''
        文章ごとの重要度を近接した文で頻出する度合いで点数化し、スコアリングする

        Args:
            normalized_sentences:   一文一要素として格納したリスト。
            top_n_words:            要約対象文の個数。返り値のリストの要素数もこれに比例。

        Returns:
            メソッド：summarizeの返り値のキー：scoring_dataと等価のデータとなる。
            もともとのオライリー本の関数からアルゴリズム的な変更は加えていない。
            （逆に言えば、まだこのメソッドは細分化や再メソッド化の余地があるということでもある。）

        '''
        scores_list = []
        sentence_idx = -1

        for sentence in normalized_sentences:
            self.tokenize(sentence)
            sentence = self.token

            sentence_idx += 1
            word_idx = []

            # 重要度の高いトークンごとにそのキーを特定していく
            for w in top_n_words:
                # 重要なトークンがどの文で頻出するのかを指標化する
                try:
                    word_idx.append(sentence.index(w))
                # トークンが文に含まれていない場合は、特に何もしない。
                except ValueError:
                    pass

            word_idx.sort()

            # 幾つかの文は、どの重要なトークンも含んでいない場合も想定できる。
            if len(word_idx) == 0:
                continue

            # 近距離の頻出トークンごとにクラスタリングする
            clusters = []
            cluster = [word_idx[0]]
            i = 1
            while i < len(word_idx):
                if word_idx[i] - word_idx[i - 1] < self.cluster_threshold:
                    cluster.append(word_idx[i])
                else:
                    clusters.append(cluster[:])
                    cluster = [word_idx[i]]
                i += 1
            clusters.append(cluster)

            # クラスタごとに点数化する
            max_cluster_score = 0
            for c in clusters:
                significant_words_in_cluster = len(c)
                total_words_in_cluster = c[-1] - c[0] + 1
                score = 1.0 * significant_words_in_cluster \
                    * significant_words_in_cluster / total_words_in_cluster

                if score > max_cluster_score:
                    max_cluster_score = score

            scores_list.append((sentence_idx, score))

        return scores_list


def copy_list_into_dir(file_list,dir_path):
    num = 0
    for file_name in file_list:
        shutil.copyfile(file_name,dir_path+"/"+str(num)) # testディレクトリにコピー
        num += 1


def convert_pdf_to_html(path):
    from pdfminer.pdfparser import PDFParser, PDFDocument
    from pdfminer.pdfinterp import PDFResourceManager, PDFPageInterpreter
    from pdfminer.converter import PDFPageAggregator, HTMLConverter
    from pdfminer.layout import LAParams, LTTextBox, LTTextLine
    import io

    fp = open(path, 'rb')
    parser = PDFParser(fp)
    doc = PDFDocument()
    parser.set_document(doc)
    doc.set_parser(parser)
    doc.initialize('')
    rsrcmgr = PDFResourceManager()
    laparams = LAParams()
    outfp = io.open('temp.html', 'wt', encoding='utf-8', errors='ignore')
    # device = PDFPageAggregator(rsrcmgr, laparams=laparams)
    device = HTMLConverter(rsrcmgr, outfp, scale=1, layoutmode='normal',laparams=laparams, showpageno=False)
    interpreter = PDFPageInterpreter(rsrcmgr, device)
    # Process each page contained in the document.
    for page in doc.get_pages():
        interpreter.process_page(page)
        # layout = device.get_result()
        # for lt_obj in layout:
        #     if isinstance(lt_obj, LTTextBox) or isinstance(lt_obj, LTTextLine):
        #         print(lt_obj.get_html())
    fp.close()
    device.close()
    outfp.close()


def main():
    fdir = os.getcwd()
    os.chdir(THESIS_DIR)
    file_list = glob.glob('**/*.pdf',recursive=True)
    thesis_dir = []
    chapter = re.compile(TOKEN)
    footer = re.compile(FOOTER)
    content = re.compile('<.+?>')
    student_data = re.compile(STUDENT_DATA)
    # print(file_list)
    os.chdir(fdir)
    # print(os.getcwd())
    for tdir in file_list:
        fdir = THESIS_DIR+tdir
        tdata = PdfFileReader(fdir)
        if tdata.getNumPages() <= 2:
            thesis_dir.append(fdir)
    # print(thesis_dir)
    database = pd.DataFrame(columns=['id','name','abstract'])
    for thesis in thesis_dir:
        print(thesis)
        convert_pdf_to_html(thesis)
        html = open('temp.html','r')
        document = html.read()
        html.close()
        result = []
        purse = chapter.split(document)
        # print(len(purse))
        if purse[0].find('情報テクノロジー学科') != -1 and purse[0].find('著者紹介') == -1:
            header = content.sub('',purse[0])
            # print(header)
            student_list = student_data.findall(header)
            for text in purse[1:]:
                if len(text) != 0:
                    output = footer.sub('',text)
                    output = content.sub('',output)
                    output = re.sub('\n','',output)
                    if output.find('参考文献') == -1:
                        result.append(output)

            auto_abstractor = AutoAbstractor()
            abstractable_doc = AbstractableTopNRank()
            result_list = auto_abstractor.summarize("".join(result), abstractable_doc)
            abstract = "".join(result_list["summarize_result"])
            # print(abstract)
            for name,sid in student_list:
                d = {'id':sid, 'name':name, 'abstract':abstract}
                instance = pd.DataFrame(d,columns=['id','name','abstract'],index=[0])
                database = database.append(instance,ignore_index=True)

    database.set_index('id')
    database.to_json('output.json',force_ascii=False)
if __name__ == '__main__':
    main()
