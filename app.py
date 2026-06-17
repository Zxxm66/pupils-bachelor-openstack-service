from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Optional
import json
import os

DATA_FILE = os.path.join(os.path.dirname(__file__), 'students.json')

app = FastAPI(
    title="pupils-bachelor-openstack-service",
    description=(
        "Учебный FastAPI-сервис для определения студентов, "
        "которые могут стать бакалаврами."
    ),
    version="1.0.0",
)


class Student(BaseModel):
    name: str
    course: int
    grade: float
    attended_labs: int
    specialization: Optional[str] = None


def load_students() -> List[dict]:
    with open(DATA_FILE, 'r', encoding='utf-8') as f:
        return json.load(f)


@app.get("/", summary="Read Root")
def read_root():
    return {
        "service": "pupils-bachelor-openstack-service",
        "docs": "/docs",
    }


@app.get("/health", summary="Health Check")
def health_check():
    return {"status": "ok"}


@app.get("/students", response_model=List[Student], summary="Get Students")
def get_students():
    return load_students()


@app.get("/student/{name}", response_model=Student, summary="Get Student")
def get_student(name: str):
    students = load_students()
    for student in students:
        if student["name"].lower() == name.lower():
            return student
    raise HTTPException(status_code=404, detail="Student not found")


@app.get("/bachelor", summary="Get Bachelor Candidates")
def get_bachelor_candidates():
    """
    Условия отбора кандидатов на бакалавра:
        - grade >= 4            (средний балл от 4 и выше)
        - course >= 3           (3 курс и старше)
        - attended_labs >= 75   (посещаемость лабораторных от 75%)
    """
    students = load_students()

    candidates = [
        s for s in students
        if s.get("grade", 0) >= 4
        and s.get("course", 0) >= 3
        and s.get("attended_labs", 0) >= 75
    ]

    distribution = {}
    for c in candidates:
        spec = c.get("specialization", "Unknown")
        distribution[spec] = distribution.get(spec, 0) + 1

    return {
        "message": "Список кандидатов на степень бакалавра",
        "total_candidates": len(candidates),
        "specialization_distribution": distribution,
        "candidates": candidates,
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
