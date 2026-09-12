"""Prediction routes."""
from django.urls import path

from .views import SchemaView, ModelCardView, PredictView, HistoryView

urlpatterns = [
    path("schema/", SchemaView.as_view(), name="schema"),
    path("model/card/", ModelCardView.as_view(), name="model-card"),
    path("predict/", PredictView.as_view(), name="predict"),
    path("history/", HistoryView.as_view(), name="history"),
]
