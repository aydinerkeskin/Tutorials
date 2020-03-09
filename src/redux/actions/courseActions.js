export function createCourse(course) {
  console.log("courseAction, " + JSON.stringify(course));
  return { type: "CREATE_COURSE", course: course };
}
