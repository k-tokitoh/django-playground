from django.db.models import F
from django.http import HttpResponseRedirect
from django.shortcuts import get_object_or_404, render
from django.urls import reverse
from django.views import generic

from .models import Choice, Question


class IndexView(generic.ListView):
    template_name = "polls/index.html"
    # templateでこの名前の変数に、get_queryset()の返り値が詰め込まれる
    context_object_name = "latest_question_list"

    def get_queryset(self):
        return Question.objects.order_by("-pub_date")[:5]


# 以下と等価
# def index(request):
#     latest_question_list = Question.objects.order_by("-pub_date")[:5]
#     # {application}/templates の中を探してくれる
#     context = {
#         "latest_question_list": latest_question_list,
#     }
#     return render(request, "polls/index.html", context)
#     # render()というショートカットは以下と等価
#     # from django.template import loader
#     # template = loader.get_template("polls/index.html")
#     # return HttpResponse(template.render(context, request))


def detail(request, question_id):
    question = get_object_or_404(Question, pk=question_id)
    # 以下と等価
    # from django.http import Http404
    # try:
    #     question = Question.objects.get(pk=question_id)
    # except Question.DoesNotExist:
    #     raise Http404("Question does not exist")
    return render(request, "polls/detail.html", {"question": question})


class ResultsView(generic.DetailView):
    model = Question
    template_name = "polls/results.html"


# 以下と等価
# `model = Question`によって、templateに{"question": question}を渡すところまでやってくれるのか！！
# def results(request, question_id):
#     question = get_object_or_404(Question, pk=question_id)
#     return render(request, "polls/results.html", {"question": question})


# シンプルにdispatchするだけだと、methodは区別しないらしい
def vote(request, question_id):
    question = get_object_or_404(Question, pk=question_id)
    try:
        selected_choice = question.choice_set.get(pk=request.POST["choice"])
    except (KeyError, Choice.DoesNotExist):
        # 詳細画面にエラーメッセージつきでリダイレクトする
        return render(
            request,
            "polls/detail.html",
            {
                "question": question,
                "error_message": "有効な回答が選択されていません",
            },
        )
    else:
        # F()をつかうと競合状態を避けることができる
        # https://docs.djangoproject.com/ja/5.1/ref/models/expressions/#avoiding-race-conditions-using-f
        selected_choice.votes = F("votes") + 1
        selected_choice.save()
        # postをそのまま201とかで返しちゃうと、ブラウザの戻るボタンでpostが再送信されてしまう
        # getリクエストにリダイレクトしておけば、戻るボタンではリダイレクト後のページにアクセスするだけで、再送信を防げる
        return HttpResponseRedirect(reverse("polls:results", args=(question.id,)))
